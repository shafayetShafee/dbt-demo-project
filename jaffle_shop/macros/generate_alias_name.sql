{% macro generate_alias_name(custom_alias_name=none, node=none) -%}

    {%- if custom_alias_name -%}

        {{ custom_alias_name | trim }}

    {%- else -%}

        {{ node.name }}

    {%- endif -%}

{%- endmacro %}