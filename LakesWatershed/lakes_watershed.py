# import modules

import pandas as pd
import matplotlib.pyplot as plt
import os

# df = pd.read_csv('data/Lakes_SurfaceData_2012-2019.csv')
# df = df[['STA_SEQ', 'YLat', 'XLong']]
# df = df.drop_duplicates()
# df.to_csv('LakeSampleSites_2012_2019.csv', index=False)

lakes = pd.read_csv('data/Lakes_2012-2019_HSI_GNISID.csv')

lakes.columns

