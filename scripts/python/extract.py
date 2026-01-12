import glob
import json
import pprint as pp
import re
import sys

uitvoer = None
base = ""

def stderr(text,nl='\n'):
    sys.stderr.write(f"{text}{nl}")

def group(label,subfields):
    rows = []
    for field in subfields:
        row = [field['key'],label.replace('?','')]
        row.append(field['name'])
        row.append(field['label'])
        row.append(str(field['required']))
        row.append('')
        row.append(field['type'])
        try:
            default = field['default_value']
            if default and default!='':
                row.append(default)
            else:
                row.append('')
        except:
                row.append('')
        if field['type']=='repeater':
            stderr(f'{field["label"]}: repeater')
            for s_field in field['sub_fields']:
                stderr(f"\t{s_field['label']} ({s_field['type']})")
            row.append('')
        elif field['type']=='select':
            stderr(f'{field["label"]}: select')
            choices = []
            for key in field['choices']:
                stderr(f"\t{key}")
                choices.append(key)
            choices = '|'.join(choices)
            row.append(choices)
        elif field['type']=='checkbox':
            stderr(f'{field["label"]}: checkbox')
            choices = []
            for key in field['choices']:
                stderr(f"\t{key}")
                choices.append(key)
            choices = '|'.join(choices)
            row.append(choices)
        elif field['type']=='radio':
            stderr(f'{field["label"]}: radio')
            choices = field['choices']
            choice = []
            for key in choices:
                stderr(f"\t{key}: {choices[key]}")
                choice.append(key)
            choice = '|'.join(choice)
            row.append(choice)
        else:
            row.append('')
        rows.append(row)
#    stderr(rows)
    return rows

if __name__ == "__main__":
    lookup = ['Place','Crossing','Individual','Organisation']
    result = {}
    groups = []
    allFiles = {}
    all_files = glob.glob("WP-schema/*.json")
    for f in sorted(all_files):
        res = json.load(open(f))
        title = res['title']
        if title in lookup:
            result[title] = []
            stderr(f'\n{res["key"]}: {title}')
            for field in res['fields']:
                row = [res['key'],title]
                row.append(field['name'])
                row.append(field['label'])
                row.append(str(field['required']))
                row.append('')
                row.append(field['type'])
                try:
                    default = field['default_value']
                    if default and default!='':
                        row.append(default)
                    else:
                        row.append('')
                except:
                    row.append('')
                if field['type']=='repeater':
                    stderr(f'{field["label"]}: repeater')
                    new_group = group(field['label'],field['sub_fields'])
                    for key in new_group:
                        result[field['label']] = new_group
                    for s_field in field['sub_fields']:
                        stderr(f"\t{s_field['label']} ({s_field['type']})")
                    row.append('')
                elif field['type']=='select':
                    stderr(f'{field["label"]}: select')
                    choices = []
                    for key in field['choices']:
                        stderr(f"\t{key}")
                        choices.append(key)
                    choices = '|'.join(choices)
                    row.append(choices)
                elif field['type']=='checkbox':
                    stderr(f'{field["label"]}: checkbox')
                    choices = []
                    for key in field['choices']:
                        stderr(f"\t{key}")
                        choices.append(key)
                    choices = '|'.join(choices)
                    row.append(choices)
                elif field['type']=='radio':
                    stderr(f'{field["label"]}: radio')
                    choices = field['choices']
                    choice = []
                    for key in choices:
                        stderr(f"\t{key}: {choices[key]}")
                        choice.append(key)
                    choice = '|'.join(choice)
                    row.append(choice)
                elif field['type']=='group':
                    stderr(f'{field["label"]}: group')
                    new_group = group(field['label'],field['sub_fields'])
                    for key in new_group:
                        result[field['label']] = new_group
                    for s_field in field['sub_fields']:
                        if s_field['label'].strip()!='':
                            stderr(f"\t{s_field['label']} ({s_field['type']})")
                        else:
                            stderr(f"\t- {s_field['name']} ({s_field['type']})")
                    row.append('')
                else:
                    row.append('')
                result[title].append(row)
    for group in groups:
        result[group['title']] = group

#    stderr(f'{len(all_files)} files')
#    pp.pprint(result)

    uitvoer = open('tastade.csv','w')
    uitvoer.write('source;entiteit;veld;label;min;max;type;default;choice_list\n')
    for key in result:
        for row in result[key]:
            uitvoer.write(';'.join(row)+'\n')
