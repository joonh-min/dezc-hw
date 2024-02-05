import re

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    """
    Remove rows where the passenger count is equal to 0 or the trip distance is equal to zero.
    Create a new column lpep_pickup_date by converting lpep_pickup_datetime to a date.
    Rename columns in Camel Case to Snake Case, e.g. VendorID to vendor_id.
    Add three assertions:
    vendor_id is one of the existing values in the column (currently)
    passenger_count is greater than 0
    trip_distance is greater than 0
    """
    # Remove rows with 0 passenger and 0 trip distance
    print(f"Number of rows with zero passengers: {data.query('passenger_count == 0').shape[0]}, with zero trip distance {data.query('trip_distance == 0').shape[0]}")
    data = data.query("passenger_count > 0 & trip_distance > 0") # NOTE: I think it is better to do '>' than not equal zero, to avoid negetive outliers.
    # Verif:
    print(f"Number of rows with zero passengers: {data.query('passenger_count == 0').shape[0]}, with zero trip distance {data.query('trip_distance == 0').shape[0]}")

    # Create a new column `lpep_pickup_date`
    data["lpep_pickup_date"] = data.lpep_pickup_datetime.dt.date
    print(f"is lpep_pickup_date created? : {'lpep_pickup_date' in data.columns}")

    prev_cols = data.columns

    # Column names, Camel -> Snake
    data.columns = [re.sub(r'(?<=[a-z])(?=[A-Z])', r'_', col).lower() for col in data.columns]

    # Question 5. Data Transformation: How many columns need to be renamed to snake case?
    print(f"The changed number of columns are : {len(set(data.columns) - set(prev_cols))}")

    # Question 6. Data Exporting: Once exported, how many partitions (folders) are present in Google Cloud?
    # NOTE: it should be equal to the number of unique dates in column `lpep_pickup_date`
    print(len(data.lpep_pickup_date.unique()))
    print(data.lpep_pickup_date.max())

    return data


@test
def test_output(output, *args) -> None:
    """
    """
    print(output.vendor_id.unique())
    assert all(output.vendor_id.isin(output.vendor_id.unique())), "The column `vendor_id` does not exist."
    assert output.passenger_count.min() > 0, "There is(are) row(s) with passenger_count less than zero."
    assert output.trip_distance.min() > 0, "There is(are) row(s) with trip_distance less than zero."
