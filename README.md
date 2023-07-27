# abap_date_converter
Simple utility to convert date in any output format.

Can be called like below
DATA lo_date TYPE REF TO zcl_date_utils.


lo_date =  NEW #( iv_date = sy-datum                             "--- Input date

                  iv_custom_format = 'MMDDYYYY'                  "pass format in any order formed with MM, MMM, DD, YY, YYYY like MMDDYY or MMDDYYY or DDMMYYYY or DDMMMYYYY etc.. leaving blank will pick user format
									
                  iv_custom_separator = '/'                      "any character to separate date. leaving blank will pick from user format
									
                  iv_space_separator = abap_false ).             "To have space as date separator.
