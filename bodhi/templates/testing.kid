<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'master.kid'">

<head>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" py:replace="''"/>
    <title>Fedora Updates</title>
</head>

<body>
    &nbsp;&nbsp;<b>${release} Testing Updates</b>
    <div class="list">
        <span py:for="page in tg.paginate.pages">
            <a py:if="page != tg.paginate.current_page"
                href="${tg.paginate.get_href(page)}">${page}</a>
            <b py:if="page == tg.paginate.current_page">${page}</b>
        </span>
        <a href="?tg_paginate_limit=${num_items}">all</a>
    </div>

    <table class="list">
        <tr class="list">
            <th class="list">
                <b>ID</b>
            </th>
            <th class="list">
                <b>Package</b>
            </th>
            <th class="list">
                <center><b>Type</b></center>
            </th>
            <th class="list">
                <center><b>Karma</b></center>
            </th>
            <th class="list">
                <center><b>Submitter</b></center>
            </th>
            <th class="list">
                <b>Date Pushed</b>
            </th>
        </tr>
        <?python row_color = "#FFFFFF" ?>
        <tr class="list" bgcolor="${row_color}" py:for="update in updates">
            <td class="list">
                ${update.update_id}
            </td>
            <td class="list">
                <a class="list" href="${tg.url(update.get_url())}">${update.title.replace(',', ', ')}</a>
            </td>
            <td class="list" align="center">
                <img src="${tg.url('/static/images/%s.png' % update.type)}" title="${update.type}" />
            </td>
            <?python
            if update.karma < 0: karma = -1
            elif update.karma > 0: karma = 1
            else: karma = 0
            ?>
            <td class="list" align="center">
                <img src="${tg.url('/static/images/karma%d.png' % karma)}" align="top"/> <b>${update.karma}</b>
            </td>
            <td class="list">
                ${update.submitter}
            </td>
            <td class="list">
                ${update.date_pushed}
            </td>
            <?python row_color = (row_color == "#f1f1f1") and "#FFFFFF" or "#f1f1f1" ?>
        </tr>
    </table>

</body>
</html>
