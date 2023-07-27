class ZCL_DATE_UTILS definition
  public
  final
  create public .

public section.

  data MV_DATE type SY-DATUM read-only .
  data MV_DATE_FORMAT type CHAR10 read-only .
  data MV_DATE_SEPARATOR type CHAR1 read-only .

  methods CONSTRUCTOR
    importing
      value(IV_DATE) type SY-DATUM
      value(IV_CUSTOM_FORMAT) type CHAR10 optional
      value(IV_CUSTOM_SEPARATOR) type CHAR1 optional
      value(IV_SPACE_SEPARATOR) type FLAG optional .
  methods GET_DATE
    returning
      value(RV_DATE) type STRING .
protected section.
private section.

  data MV_DD type CHAR2 .
  data MV_MM type CHAR2 .
  data MV_MMM type CHAR3 .
  data MV_YY type CHAR2 .
  data MV_YYYY type CHAR4 .
  data MV_FIRST type CHAR4 .
  data MV_SECOND type CHAR4 .
  data MV_LAST type CHAR4 .

  methods _GET_DATE_SEGMENT
    importing
      value(IV_SEGMENT) type CHAR4
    returning
      value(RV_SEGMENT) type CHAR4 .
ENDCLASS.



CLASS ZCL_DATE_UTILS IMPLEMENTATION.


  METHOD constructor.
    DATA: lv_position TYPE i,
          lv_char(4)  TYPE c,
          lv_index    TYPE i,
          lv_c        TYPE c.

    "Save the incoming data
    mv_date = iv_date.

*-- Get User format.
    SELECT SINGLE datfm
             FROM usr01
             INTO @DATA(lv_datfm)
            WHERE bname = @sy-uname.

*-- Determine the date separator
    IF iv_space_separator = abap_true.
      mv_date_separator = space.
    ELSEIF iv_custom_separator IS NOT INITIAL.
      mv_date_separator = iv_custom_separator.
    ELSE.
      "Get user default date separator
      "Note: Non English dates are ignored
      mv_date_separator = SWITCH #( lv_datfm
                       WHEN '1' OR '4'
                         THEN '.'
                       WHEN '2' OR '5'
                         THEN '/'
                       WHEN '3' OR '6'
                         THEN '-'
                       ELSE '/' ).
    ENDIF.

*-- Split date to day month and Year
    mv_dd = iv_date+6(2). "Date
    mv_mm = iv_date+4(2). "Month in numbers
    mv_yyyy = iv_date(4). "Year
    mv_yy = iv_date+2(2). "2 digit year
    mv_mmm = COND #( WHEN mv_mm = '01' "Month long form
                      THEN 'Jan'
                     WHEN mv_mm = '02'
                      THEN 'Feb'
                     WHEN mv_mm = '03'
                      THEN 'Mar'
                     WHEN mv_mm = '04'
                      THEN 'Apr'
                     WHEN mv_mm = '05'
                      THEN 'May'
                     WHEN mv_mm = '06'
                      THEN 'Jun'
                     WHEN mv_mm = '07'
                      THEN 'Jul'
                     WHEN mv_mm = '08'
                      THEN 'Aug'
                     WHEN mv_mm = '09'
                      THEN 'Sep'
                     WHEN mv_mm = '10'
                      THEN 'Oct'
                     WHEN mv_mm = '11'
                      THEN 'Nov'
                     WHEN mv_mm = '12'
                      THEN 'Dec' ).

*-- Set format when not available
    IF iv_custom_format IS NOT INITIAL.
      mv_date_format = iv_custom_format.
    ELSE.
      mv_date_format = SWITCH #( lv_datfm
                       WHEN '1'
                         THEN 'DDMMYYYY'
                       WHEN '2' OR '3'
                         THEN 'MMDDYYYY'
                       WHEN '4' OR '5' OR '6'
                         THEN 'YYYYMMDD'
                       ELSE 'DDMMYYYY' ).
    ENDIF.

    DATA(lv_length) = strlen( mv_date_format ).
    DO lv_length TIMES.
      IF lv_c <> mv_date_format+lv_index(1).
        lv_position = lv_position + 1.
      ENDIF.

      lv_c = mv_date_format+lv_index(1).

      IF lv_position = 1.
        mv_first = |{ mv_first }{ lv_c }|. "Keep adding tyhe chars
      ELSEIF lv_position = 2.
        mv_second = |{ mv_second }{ lv_c }|.
      ELSEIF lv_position = 3.
        mv_last = |{ mv_last }{ lv_c }|.
      ENDIF.
      lv_index = lv_index + 1.
    ENDDO.
  ENDMETHOD.


  METHOD get_date.

    "Get output date
    DATA(lv_first) = _get_date_segment( mv_first ).
    DATA(lv_second) = _get_date_segment( mv_second ).
    DATA(lv_last) = _get_date_segment( mv_last ).

    CONCATENATE lv_first lv_second lv_last INTO rv_date SEPARATED BY mv_date_separator.
  ENDMETHOD.


  METHOD _get_date_segment.
    "Return the segment of the date
    rv_segment = SWITCH #( iv_segment
                           WHEN 'DD'
                            THEN mv_dd
                           WHEN 'MM'
                            THEN mv_mm
                           WHEN 'MMM'
                            THEN mv_mmm
                           WHEN 'YY'
                            THEN mv_yy
                           WHEN 'YYYY'
                            THEN mv_yyyy ).
  ENDMETHOD.
ENDCLASS.
