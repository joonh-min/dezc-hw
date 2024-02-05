import io
import pandas as pd
import requests

if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data_from_api(*args, **kwargs):
    """
    CSV url format: https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_{YYYY}-{MM}.csv.gz
    """
    
    url_template = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_{year}-{month:02d}.csv.gz"
    
    target_year = 2020
    target_mon = [10, 11, 12] # Q4 Months

    taxi_dtypes = {
        "vendorID": pd.Int64Dtype(),
        "store_and_fwd_flag": pd.CategoricalDtype(),
        "RatecodeID": pd.Int64Dtype(),
        "PULocationID": pd.Int64Dtype(),
        "DOLocationID": pd.Int64Dtype(),
        "passenger_count": pd.Int64Dtype(),
        "trip_distance": float,
        "fare_amount": float,
        "extra": float,
        "mta_tax": float,
        "tip_amount": float,
        "tolls_amount": float,
        "ehail_fee":  float,
        "improvement_surchage": float,
        "total_amount": float,
        "payment_type": pd.Int64Dtype(),
        "trip_type": pd.Int64Dtype(),
        "congestion_surcharge": float,
    }

    parse_dates = ["lpep_pickup_datetime", "lpep_dropoff_datetime"]

    dfs = []
    for mon in target_mon:
        dfs.append(pd.read_csv(url_template.format(year=target_year, month=mon),
                   compression="gzip",
                   dtype=taxi_dtypes,
                   parse_dates=parse_dates))

    res_df = pd.concat(dfs)

    return res_df


# @test
# def test_output(output, *args) -> None:
#     """
#     Template code for testing the output of the block.
#     """
#     assert output is not None, 'The output is undefined'
