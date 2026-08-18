import importlib.util
import os
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

SCRIPT_PATH = (
    Path(__file__).parents[1]
    / "skills"
    / "image-generation"
    / "scripts"
    / "generate_image.py"
)
SPEC = importlib.util.spec_from_file_location("generate_image", SCRIPT_PATH)
assert SPEC and SPEC.loader
generate_image = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(generate_image)


class FakeResponse:
    def __init__(self, status_code=200, payload=None, content=b"", headers=None):
        self.status_code = status_code
        self._payload = payload
        self.content = content
        self.headers = headers or {}
        self.text = "" if payload is None else str(payload)

    def json(self):
        return self._payload


class AtlasImageGenerationTests(unittest.TestCase):
    def test_maps_aspect_ratio_to_atlas_dimensions(self):
        self.assertEqual(
            generate_image.atlas_size_from_aspect("16:9", "1K"),
            "1824*1024",
        )

    def test_rejects_unsupported_atlas_aspect_ratio(self):
        with self.assertRaisesRegex(generate_image.GenerationError, "exceeds 4:1"):
            generate_image.atlas_size_from_aspect("1:8", "1K")

    def test_generates_and_downloads_without_forwarding_credentials(self):
        submit_response = FakeResponse(
            payload={"code": 200, "data": {"id": "pred-1", "status": "created"}}
        )
        processing_response = FakeResponse(
            payload={"code": 200, "data": {"id": "pred-1", "status": "processing"}}
        )
        completed_response = FakeResponse(
            payload={
                "code": 200,
                "data": {
                    "id": "pred-1",
                    "status": "completed",
                    "outputs": ["https://cdn.example.com/result.png"],
                },
            }
        )
        image_response = FakeResponse(
            content=b"\x89PNG\r\n\x1a\nimage",
            headers={"content-type": "image/png"},
        )

        with TemporaryDirectory() as directory:
            output_path = str(Path(directory) / "atlas.png")
            with (
                patch.dict(os.environ, {"ATLASCLOUD_API_KEY": "test-key"}, clear=True),
                patch.object(
                    generate_image.httpx, "post", return_value=submit_response
                ) as post,
                patch.object(
                    generate_image.httpx,
                    "get",
                    side_effect=[
                        processing_response,
                        completed_response,
                        image_response,
                    ],
                ) as get,
                patch.object(generate_image.time, "sleep"),
            ):
                result = generate_image.generate_with_atlas(
                    prompt="A clean diagram",
                    output_path=output_path,
                    model=generate_image.DEFAULT_ATLAS_MODEL,
                    aspect_ratio="16:9",
                    image_size="1K",
                )

            self.assertEqual(result, output_path)
            self.assertEqual(Path(output_path).read_bytes(), image_response.content)

        post.assert_called_once()
        self.assertEqual(
            post.call_args.kwargs["json"],
            {
                "model": "qwen-image-3.0/text-to-image",
                "prompt": "A clean diagram",
                "size": "1824*1024",
            },
        )
        self.assertEqual(get.call_count, 3)
        self.assertIn("Authorization", get.call_args_list[0].kwargs["headers"])
        self.assertIn("Authorization", get.call_args_list[1].kwargs["headers"])
        self.assertNotIn("Authorization", get.call_args_list[2].kwargs["headers"])

    def test_requires_atlas_api_key(self):
        with (
            patch.dict(os.environ, {}, clear=True),
            self.assertRaisesRegex(
                generate_image.GenerationError,
                "ATLASCLOUD_API_KEY",
            ),
        ):
            generate_image.generate_with_atlas(
                prompt="A clean diagram",
                output_path="unused.png",
                model=generate_image.DEFAULT_ATLAS_MODEL,
                aspect_ratio="16:9",
                image_size="1K",
            )

    def test_auto_uses_atlas_when_it_is_the_only_configured_provider(self):
        with (
            patch.dict(os.environ, {"ATLASCLOUD_API_KEY": "test-key"}, clear=True),
            patch.object(
                generate_image,
                "generate_with_atlas",
                return_value="atlas.png",
            ) as atlas,
        ):
            result = generate_image.generate_image(
                prompt="A clean diagram",
                output_path="atlas.png",
                provider="auto",
                style_prefix="",
            )

        self.assertEqual(result, "atlas.png")
        atlas.assert_called_once()


if __name__ == "__main__":
    unittest.main()
