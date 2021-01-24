---
title: Create PDF reports with Python and Jinja2
key: A10011
tags: python jinja
category: Tech
date: 2021-01-20
---

*This post is a summary of the code I wrote in Python for my then-desperate wife to automatically generate hundreds of invoices.* 

Suppose you have an excel sheet with hundreds of rows and a couple of columns (a sample is shown below), and would like to generate pdf reports for individual rows according to column values. 
With MS office, the sheet can be imported into a word template and the column names of interest can be placed accordingly in the template. 
Then you can print pdf files for every row. However the task can easily become tedious when you have additional requirements. 
For instance, grouping customers by attributes like regions to different folders and naming the printed files with column values would need manual and repetitive efforts. 
To automate the process with Python, there are many [options](https://www.xlwings.org/blog/reporting-with-python) to choose from.
The major tool we'll make use of is [Jinja2](https://jinja2docs.readthedocs.io/en/stable/). 
In addition, we use pandas to handle tables and test a couple of html-to-pdf tools. 

## What is Jinja2?

This is excerpted from Jinja2's documentation:
> Jinja2 is a modern and designer-friendly templating language for Python, modelled after Django’s templates. It is fast, widely used and secure with the optional sandboxed template execution environment.

> The name Jinja was chosen because it’s the name of a Japanese temple and temple and template share a similar pronunciation. It is not named after the city in Uganda.

In a nutshell, Jinja bridges our Python code and html files which will be shown to end users. 
By placing placeholders `{{ ... }}` in a html template, in Python, Jinja can pass actual values to the placeholders when rendering html files. 
If this sounds too abstract, the concept will become clear when we see the code later.

## A concrete but simple example

Let's generate invoices according to the following sales table:
| ID | Invoice | Name | Address    | Item         | Cost    |
|----|---------|------|------------|--------------|---------|
| 1  | A0001   | Alix | Volkstr. 1 | book         | 12Euro  |
| 2  | A0002   | Juli | Volkstr. 2 | laptop       | 500Euro |
| 3  | A0628   | Ruo  | Volkstr. 3 | laptop | 1245Euro |

Each customer needs an invoice pdf file which is named by the customer's name. 
Our basic idea is to first generate html files and then convert them to pdf files. 

To start with, I have already composed a template html file based on this [repo](https://github.com/mjhea0/thinkful-mentor/tree/master/python/jinja):
```html
<!DOCTYPE html>
<html>
<head>
  <title>Rechnung</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" media="screen">
  <style type="text/css">
    .container {
      max-width: 800px;
      padding-top: 100px;
    }
    p {font-size: medium; text-align: left; display:flex; flex-direction: column}
    h4 {text-align: center;}
    h3 {text-align:center; color: rgb(19, 17, 17);}
  </style>
</head>
<body>
  <div class="container">
    <img src="file:///home/linlin/projects/auto_report/jinja_report/yinyang1.png" style="float: left; WIDTH:80px; HEIGHT:80px"/>
    <h3> <b>很酷的报告</b></h3>
    <h4><b>A cool report by Jinja2</b></h4>
    
    <p style="text-align:center; font-size: small;">Volkstr. 001, 000000 Peaceland
    <br>
    Tel: 88-88888888,   Fax: 00-00000000
    <br>
    Email: abc@xxx.xx,   web: linlinzhao.com
    </p>
    <br>
   <p>Name: {{name}}</p>
   <p>Address: {{address}}</p>
   <!--ul>
     {% for n in my_list %}
     <li>{{n}}</li>
     {% endfor %}
   </ul !-->
   <br>
   <br>
   <h5 style="font-size: large;"><b>Rechnung</b></h5>
   <p>Invoice No.: {{invoice}}</p>
   <p>Date: {{date}}</p>
   <p>Item: {{item}}</p>
   <p>Cost: {{amount}}</p>

    <br>
    <p>
    Beautiful is better than ugly.<br>
    Explicit is better than implicit.<br>
    Simple is better than complex.<br>
    Complex is better than complicated.<br>
    Flat is better than nested.<br>
    Sparse is better than dense.<br>
    Readability counts.<br>
    Special cases aren't special enough to break the rules.</p>
    <br>
    <br>
    <h5 style="font-size: large;"><b>Bitte in einer Woche überweisen, vielen Dank!</b></h5>
    <br>
    <div class="footer">
      {% block footer %}
      <p>Mit freundlichen Grüßen</p>
      <br>
      <p>一家很赚钱的公司</p>
      <p>A very profitable company</p>
        <br>
        <br>

        <p style="font-size: x-small;">Kontoinhaber: NN<br>
        Eingutbank<br>
        Bankleitzahl: 000 000 00   Kontonummer:  000000000<br>
        IBAN: XX00 0000 0000 0000 0000 00  BIC: XXXXXXXX  </p>
      {% endblock %}
    </div>
  </div>
  <script src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
  <script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
</body>
</html>
```
This is how the template looks like: ![template](/assets/images/jiaja_out_html.png)
As you may see from the template, the column names in our table have corresponding placeholders.

## Use Jinja to render html files

Now we can write Python code to pass the values in the table to html files. The following function can render one html file for a given row. 
```python
import jinja2

def render_html(row):
    """
    Render html page using jinja
    """
    template_loader = jinja2.FileSystemLoader(searchpath="./")
    template_env = jinja2.Environment(loader=template_loader)
    template_file = "layout.html"
    template = template_env.get_template(template_file)
    output_text = template.render(
        name=row.Name,
        address=row.Address,
        date=get_date(),
        invoice=row.Invoice,
        item=row.Item,
        amount=row.Cost
        )

    html_path = f'{row.Name}.html'
    html_file = open(html_path, 'w')
    html_file.write(output_text)
    html_file.close()
```
What this code does:
1. tell Jinja where the template is;
2. pass values to the placeholder in the template when rendering;
3. write the rendered output to a html file.

## Read the table using Pandas

The table is stored as `sample.csv`, we can use pandas to iterate through every row to have named tuples which can then be passed to `render_html`:
```python 
df = pd.read_csv('sample.csv')
for row in df.itertuples():
    render_html(row)
```
and three html files will be generated. ![htmls](/assets/images/jiaja_out_html.png).

To check if the values are passed correctly, let's view the `ruo.html`:
![ruo](/assets/images/jiaja_ruo.png)
The output actually looks all right, which is great.


## Convert html to pdf

In python, there are also several options for converting html to pdf, [pdfkit](https://github.com/JazzCore/python-pdfkit), [weasyprint](https://weasyprint.org/), [xhtml2pdf](https://xhtml2pdf.readthedocs.io/en/latest/), to name but a few.

Several factors like the template css style and the browser for viewing the html files can make the pdfs  look quite differently from what you see from the browser. 
For instance, since the template html above has English, German and Chinese, we may need to specify encoding schemes for rendering all characters correctly. 
After playing different tools for a while, I have chosen [`pdfkit`](https://github.com/JazzCore/python-pdfkit), which is a python wrapper for `wkhtmltopdf`. 
An exhaustive list of configurations can be found [here](https://wkhtmltopdf.org/usage/wkhtmltopdf.txt). 

Again I have written a function for converting:
```python
def html2pdf(html_path, pdf_path):
    """
    Convert html to pdf using pdfkit which is a wrapper of wkhtmltopdf
    """
    options = {
        'page-size': 'Letter',
        'margin-top': '0.35in',
        'margin-right': '0.75in',
        'margin-bottom': '0.75in',
        'margin-left': '0.75in',
        'encoding': "UTF-8",
        'no-outline': None,
        'enable-local-file-access': None
    }
    with open(html_path) as f:
        pdfkit.from_file(f, pdf_path, options=options
```
Note that the specified options are from the `wkhtmltopdf` configuration list. For entries without values, simply specify them to be `None`.

## Put them all together

To have clean working folder, directories `res` and `tables` are created for saving generated files and the original table respectively.
```python
import os
import jinja2
import pdfkit
import pandas as pd
import numpy as np
from datetime import date

def render_html(row):
    """
    Render html page using jinja based on layout.html
    """
    template_loader = jinja2.FileSystemLoader(searchpath="./")
    template_env = jinja2.Environment(loader=template_loader)
    template_file = "layout.html"
    template = template_env.get_template(template_file)
    output_text = template.render(
        name=row.Name,
        address=row.Address,
        date=get_date(),
        invoice=row.Invoice,
        item=row.Item,
        amount=row.Cost
        )

    html_path = f'./res/{row.Name}.html'
    html_file = open(html_path, 'w')
    html_file.write(output_text)
    html_file.close()
    print(f"Now converting {row.Name} ... ")
    pdf_path = f'./res/{row.Name}.pdf'    
    html2pdf(html_path, pdf_path)   

def html2pdf(html_path, pdf_path):
    """
    Convert html to pdf using pdfkit which is a wrapper of wkhtmltopdf
    """
    options = {
        'page-size': 'Letter',
        'margin-top': '0.35in',
        'margin-right': '0.75in',
        'margin-bottom': '0.75in',
        'margin-left': '0.75in',
        'encoding': "UTF-8",
        'no-outline': None,
        'enable-local-file-access': None
    }
    with open(html_path) as f:
        pdfkit.from_file(f, pdf_path, options=options)

def get_date():
    "Get today's date in German format"
    today = date.today()
    return today.strftime("%d.%m.%Y")

if __name__ == "__main__":

    df = pd.read_csv('tables/sample.csv')
    for row in df.itertuples():
        render_html(row)
```
Running the script would generate both html files and pdf files for all rows. The code is also available on [github](https://github.com/Linlinzhao/jinja-report).

### Code dependencies

System wide: `wkhtmltopdf`, installers for different OS can be found [here](https://wkhtmltopdf.org/downloads.html).

Python3:
- pdfkit
- jinja2
- pandas
