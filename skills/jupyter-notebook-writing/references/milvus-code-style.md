# Milvus Code Style Guidelines


## Create Collection Best Practices

There are two ways to create a collection in Milvus:
### Simple way
Use the `create_collection()` method to create a collection with default settings.
```python
from pymilvus import MilvusClient

client = MilvusClient(...)

client.create_collection(
    collection_name="demo_collection",
    dimension=768,  # This is a demo dimension for the vector field
)
```
In the above setup,
- The primary key and vector fields use their default names (`id` and `vector`).
- The primary key field accepts integers and does not automatically increments.
- There is an `AUTOINDEX` type index on the vector field, and the metric type is set to its default value (`COSINE`).
- The dynamic field feature is enabled by default.
> Milvus allows you to insert entities with flexible, evolving structures through a special feature called the dynamic field. This field is implemented as a hidden JSON field named $meta, which automatically stores any fields in your data that are not explicitly defined in the collection schema.

If the scenario is simple and the simple way is enough, you can use this simple way to create a collection. Otherwise, you can use the complex way to create a collection.

### Complex way
Manually create the schema, the index parameters and then use the `create_collection()` method to create a collection with them.

For example:

```python
from pymilvus import MilvusClient

client = MilvusClient(...)

schema = client.create_schema(auto_id=False, enable_dynamic_field=True)
schema.add_field(field_name="id", datatype=DataType.INT64, is_primary=True)
schema.add_field(field_name="vector", datatype=DataType.FLOAT_VECTOR, dim=768)
schema.add_field(field_name="text", datatype=DataType.VARCHAR, max_length=65535)

index_params = client.prepare_index_params()
index_params.add_index(
    field_name="id",
    index_type="AUTOINDEX"
)

index_params.add_index(
    field_name="vector",
    index_type="AUTOINDEX",
    metric_type="COSINE"
)
client.create_collection(collection_name="demo_collection", schema=schema, index_params=index_params)
```

In practice, you can specify different configurations for the schema and the index parameters depending on the scenario.

## Other format advice
- You'd better include a `has_collection` check before creating a collection to avoid creating a collection that already exists.
- You'd better add a comment line setting `consistency_level="Strong"` in the `create_collection()` method.
> ```python
> client.create_collection(
>     collection_name=collection_name,
>     dimension=5,
>     # Strong consistency waits for all loads to complete, adding latency with large datasets
>     # consistency_level="Strong", # Supported values are (`"Strong"`, `"Session"`, `"Bounded"`, `"Eventually"`).
> )
> ```
  But if you find this description too verbose, you can just simply omit these lines.

- No need to explicitly load the collection using `load_collection()` after creating it, because the collection is loaded automatically when it is created.

- When the first time you connect to a Milvus server using uri or token, you need to provide the blockquote block for the explanation of the connection options, like this:
> As for the argument of `MilvusClient`:
> - Setting the `uri` as a local file, e.g.`./milvus.db`, is the most convenient method, as it automatically utilizes [Milvus Lite](https://milvus.io/docs/milvus_lite.md) to store all data in this file.
> - If you have large scale of data, you can set up a more performant Milvus server on [docker or kubernetes](https://milvus.io/docs/quickstart.md). In this setup, please use the server uri, e.g.`http://localhost:19530`, as your `uri`.
> - If you want to use [Zilliz Cloud](https://zilliz.com/cloud), the fully managed cloud service for Milvus, adjust the `uri` and `token`, which correspond to the [Public Endpoint and Api key](https://docs.zilliz.com/docs/on-zilliz-cloud-console#free-cluster-details) in Zilliz Cloud.
