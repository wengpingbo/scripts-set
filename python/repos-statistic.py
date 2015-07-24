#!/usr/bin/env python
# coding: utf-8

import pygithub3
import argparse
from operator import attrgetter,itemgetter

gh = None


def gather_repos(organization, no_forks=True, org=True):
    if org:
        all_repos = gh.repos.list_by_org(organization, type='all').all()
    else:
        all_repos = gh.repos.list(user=organization).all()

    a = []
    for repo in all_repos:

        # Don't print the urls for repos that are forks.
        if no_forks and repo.fork:
            continue

        s = {}
        s['name'] = repo.name.encode('utf-8').strip()
        #s['description'] = repo.description.encode('utf-8').strip()
        s['created_at'] = repo.created_at
        s['updated_at'] = repo.updated_at
        s['open_issues'] = repo.open_issues
        s['forks'] = repo.forks
        #s['watchers'] = repo.watchers
        s['stargazers_count'] = repo.stargazers_count

        a.append(s)
    return a

if __name__ == '__main__':
    gh = pygithub3.Github()
    
    # set up args
    parser = argparse.ArgumentParser(description="Grap the whole repos' statistic data of a user or orgs from github, and print it in gfm format")
    parser.add_argument("-u", "--user", help="list user repos instead of orgs", action="store_true", default=False)
    parser.add_argument("-n", "--name", help="github name")
    parser.add_argument("-l", "--length", type=int, help="print repo length", default=10)

    args = parser.parse_args()

    repos = gather_repos(args.name, org=not args.user)
    repos_n = sorted(repos, key=itemgetter('stargazers_count'), reverse=True)

    # print table header
    print """
| 项目名称 | 创建日期 | 最后更新日期 | BUG 数 | Fork 次数 | Star 次数 |
|:------|:------:|:------:|:------:|:------:|:------:|"""

    l = args.length if len(repos_n) > args.length else len(repos_n)
    for i in range(l):
        print '| {name} | {created_at:%Y/%m/%d} | {updated_at:%Y/%m/%d} | {open_issues} | {forks} | {stargazers_count} |'.format(**repos_n[i])
