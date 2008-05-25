<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<?python import sitetemplate ?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#" py:extends="sitetemplate">

<head py:match="item.tag=='{http://www.w3.org/1999/xhtml}head'" py:attrs="item.items()">
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" py:replace="''"/>
    <meta name="robots" content="noindex,nofollow" />
    <link rel="shortcut icon" type="image/vnd.microsoft.icon" href="${tg.url('/static/images/favicon.ico')}" /> 
    <link rel="shortcut icon" type="image/x-icon" href="${tg.url('/static/images/favicon.ico')}" /> 
    <title py:replace="''">Your title goes here</title>
    <script type="text/javascript" charset="utf-8" src="${tg.url('/static/js/jquery.js')}"></script>
    <script type="text/javascript" charset="utf-8" src="${tg.url('/static/js/jquery.corner.js')}"></script>

    <meta py:replace="item[:]"/>
    <style type="text/css">
        #pageLogin
        {
            font-size: 10px;
            font-family: verdana;
            text-align: right;
        }
    </style>
    <style type="text/css" media="screen">
        @import "${tg.url('/static/css/layout.css')}";
    </style>
</head>

<body py:match="item.tag=='{http://www.w3.org/1999/xhtml}body'" py:attrs="item.items()">

<?python
from bodhi.model import Release, PackageUpdate, Releases
from bodhi.search import search_form
from sqlobject.sqlbuilder import AND
?>

<!-- Make any form submission change the bodhi logo into a spinner -->
<script type="text/javascript">
$(document).ready(function() {
    $("form").submit( function() {
        $("div[@id=bodhi-logo]").hide();
        $("div[@id=wait]").show();
    } );
} );
</script>
<script type="text/javascript">
    $(document).ready(function() {
        $('div.flash').corner();
        $('div.flash').show("slow");
    });
</script>
<script type="text/javascript" py:if="'releng' in tg.identity.groups">
$(document).ready(function() {
    $('#administration').click( function() { $('#adminlist').toggle('slow'); });
});
</script>

    <!-- header BEGIN -->
    <div id="fedora-header">
        <div id="fedora-header-logo">
            <a href="${tg.url('/')}"><img src="${tg.url('/static/images/header-fedora_logo.png')}" /></a>
        </div>

        <div id="fedora-header-items">
            <table><tr><td> ${search_form.display()} </td><td>
                <div id="bodhi-logo">
                    <a href="${tg.url('/')}"><img src="${tg.url('/static/images/bodhi-icon-48.png')}" /></a>
                </div>
                <div id="wait" style="display: none">
                    <img src="${tg.url('/static/images/wait.gif')}" height="48" width="48"/>
                </div>
            </td></tr></table>
        </div>
    </div>

    <div id="fedora-nav"></div>
    <!-- header END -->

   <!-- leftside BEGIN -->
    <div id="fedora-side-left">
        <div id="fedora-side-nav-label">Site Navigation:</div>
            <div py:if="not tg.identity.anonymous and 'releng' in tg.identity.groups">
                <ul id="fedora-side-nav">
                    <li><a id="administration" href="#">Administration</a></li>
                    <div id="adminlist" style="display: none">
                        <ul>
                            <li><a href="${tg.url('/admin/push')}">Requests</a></li>
                            <li><a href="${tg.url('/admin/masher')}">Masher</a></li>
                        </ul>
                    </div>
                </ul>
            </div>
            <div py:if="not tg.identity.anonymous and 'security_respons' in tg.identity.groups">
                <ul id="fedora-side-nav">
                    <li><a href="${tg.url('/security')}">Security Queue</a></li>
                </ul>
            </div>
            <ul id="fedora-side-nav">
                <li py:if="not tg.identity.anonymous"><a href="${tg.url('/')}">${tg.identity.user_name}'s Home</a></li>
                <li py:if="not tg.identity.anonymous"><a href="${tg.url('/mine')}">My Updates (${PackageUpdate.select(PackageUpdate.q.submitter == tg.identity.user_name).count()})</a></li>
                <li py:if="not tg.identity.anonymous"><a href="${tg.url('/new')}">New Update</a></li>
                <li py:for="release in Releases().data">
                  <a id="${release['name']}" href="${tg.url('/%s' % release['name'])}">${release['long_name']}</a>
                  <div id="${release['name']}_releases">
                    <ul>
                      <li class="release">
                        <a href="${tg.url('/metrics?release=%s' % release['name'])}" class="link">Metrics</a><a href="${tg.url('/metrics?release=%s' % release['name'])}" class="rsslink"><img src="${tg.url('/static/images/metrics-small.png')}"/></a>
                      </li>
                      <li py:for="status in ('pending', 'testing', 'stable')" class="release">
                        <a href="${tg.url('/%s/%s' % (release['name'], status != 'stable' and status or ''))}" class="link">${status.title()} (${release['num_' + status]})</a> <a href="${tg.url('/rss/rss2.0?release=%s&amp;status=%s' % (release['name'], status))}" class="rsslink"><img src="${tg.url('/static/images/rss.png')}" /></a>
                      </li>
                      <li class="release">
                        <a href="${tg.url('/%s/%s' % (release['name'], status))}" class="link">Security (${release['num_security']})</a> <a href="${tg.url('/rss/rss2.0?release=%s&amp;type=security' % release['name'])}" class="rsslink"><img src="${tg.url('/static/images/rss.png')}" /></a>
                      </li>
                    </ul>
                  </div>
                </li>
                <li class="release"><a href="${tg.url('/comments')}" class="link">Comments</a><a href="${tg.url('/rss/rss2.0?comments=True')}" class="rsslink"><img src="${tg.url('/static/images/rss.png')}" /></a>
                </li>
                <li py:if="not tg.identity.anonymous"><a href="${tg.url('/logout')}">Logout</a></li>
                <li py:if="tg.identity.anonymous"><a href="${tg.url('/login')}">Login</a></li>
            </ul>
        </div>
        <!-- leftside END -->

        <!-- content BEGIN -->
        <div id="fedora-middle-two">
            <div class="fedora-corner-tr">&nbsp;</div> 
            <div class="fedora-corner-tl">&nbsp;</div> 
            <div id="fedora-content">

            <div id="page-main">

                <center>
                    <div style="display: none;" id="flash" py:if="tg_flash" class="flash" py:content="XML(tg_flash)"></div>
                </center>
                <div py:replace="[item.text]+item[:]"/>

            </div>
        </div>
        <div class="fedora-corner-br">&nbsp;</div>
        <div class="fedora-corner-bl">&nbsp;</div>
    </div>
    <!-- content END -->

    <!-- footer BEGIN -->
    <div id="fedora-footer">Copyright © 2008  Red Hat, Inc.</div>
    <!-- footer END -->

</body>
</html>
