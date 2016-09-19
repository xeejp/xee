#!/usr/bin/env python
import json
import sys
import copy

def dumps(data):
    return json.dumps(data, sort_keys=True)

if __name__ == '__main__':
    if len(sys.argv) == 1 + 1 and sys.argv[1] == 'init':
        print(dumps({'data': {'host': [], 'participant': {}}, 'host': [], 'participant': {}}))
    elif len(sys.argv) == 3 + 1 and sys.argv[1] == 'join':
        old = json.loads(sys.argv[2])
        ID = sys.argv[3]
        if ID not in old['participant']:
            old['participant'][ID] = []
        print(dumps({'data': old, 'host': old['host'], 'participant': old['participant']}))
    elif sys.argv[1] == 'receive':
        old = json.loads(sys.argv[2])
        received = json.loads(sys.argv[3])
        if len(sys.argv) == 3 + 1:
            old['host'].append(received)
        elif len(sys.argv) == 4 + 1:
            ID = sys.argv[4]
            old['participant'][ID].append(received)
        print(dumps({'data': old, 'host': old['host'], 'participant': old['participant']}))
