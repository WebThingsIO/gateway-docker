#!/usr/bin/env python3

import argparse
import requests

BASE_URL = \
    'https://api.github.com/repos/mozilla-iot/gateway-docker/dispatches'


def main(args):
    """Script entry point."""
    data = {
        'event_type': 'build-image',
        'client_payload': {},
    }

    data['client_payload']['gateway_url'] = args.gateway_url
    data['client_payload']['gateway_branch'] = args.gateway_branch
    data['client_payload']['gateway_addon_version'] = \
        args.gateway_addon_version
    data['client_payload']['version'] = args.version

    response = requests.post(
        BASE_URL,
        headers={
            'Accept': 'application/vnd.github.everest-preview+json',
            'Authorization': 'token {}'.format(args.token),
        },
        json=data,
    )

    if response.status_code == 204:
        print('Build successfully triggered.')
        return True

    print('Failed to trigger build.')
    return False


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Trigger add-on build')
    parser.add_argument('--token', help='GitHub API token', required=True)
    parser.add_argument(
        '--gateway-url',
        help='Repository to retrieve gateway from',
        default='https://github.com/mozilla-iot/gateway',
    )
    parser.add_argument(
        '--gateway-branch',
        help='Branch or tag to retrieve from repository',
        required=True,
    )
    parser.add_argument(
        '--gateway-addon-version',
        help='Version of gateway-addon-python to use',
        required=True,
    )
    parser.add_argument(
        '--version',
        help='Version to tag',
        required=True,
    )
    args = parser.parse_args()

    main(args)
