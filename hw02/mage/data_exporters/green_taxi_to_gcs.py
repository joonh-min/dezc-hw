import os
from os import path

import pyarrow as pa
import pyarrow.parquet as pq
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.google_cloud_storage import GoogleCloudStorage
from mage_ai.settings.repo import get_repo_path
from pandas import DataFrame

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

# GCP BUCKET CONNECTION INFO
bucket_name = os.environ["bucketName"]
project_id = os.environ["projectId"]

table_name = "nyc_taxi_data"

root_path = f"{bucket_name}/{table_name}"

@data_exporter
def export_data_to_google_cloud_storage(df: DataFrame, **kwargs) -> None:
    df["lpep_pickup_date"] = df.lpep_pickup_datetime.dt.date

    table = pa.Table.from_pandas(df)

    gcs = pa.fs.GcsFileSystem()

    pq.write_to_dataset(
        table,
        root_path=root_path,
        partition_cols=['lpep_pickup_date'],
        filesystem=gcs
    )
