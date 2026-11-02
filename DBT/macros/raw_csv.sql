{# Read a raw Olist file with every column as text, so that type casting
   happens explicitly in the staging layer and is visible in code review. #}
{% macro raw_csv(file_name) -%}
    read_csv('{{ var("raw_data_path") }}/{{ file_name }}.csv', header = true, all_varchar = true, quote = '"')
{%- endmacro %}
