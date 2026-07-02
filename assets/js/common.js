var baseurl = document.querySelector('meta[name="baseurl"]').content;

document.addEventListener('DOMContentLoaded', function(){
    // Init theme
    let currentTheme = localStorage.getItem('theme');
    let isDarkMode = false;

    if (currentTheme === 'dark'){
        isDarkMode = true;
        const themeIcons = document.querySelectorAll(".ico-dark, .ico-light");

        themeIcons.forEach((ico) => {
            ico.classList.add('active');
        });
    }
    else {
        isDarkMode = false;
    }

    // navigation (mobile)
    var siteNav = document.querySelector('#navigation');
    var siteSidebar = document.querySelector('.sidebar-left');
    var menuButton = document.querySelector("#btn-nav");

    if (menuButton && siteSidebar) {
        menuButton.addEventListener('click', function() {
            if (menuButton.classList.toggle('nav-open')) {
                menuButton.setAttribute('aria-pressed', 'true');
                siteNav?.classList.add('nav-open');
                siteSidebar.classList.add('sidebar-open');
            } else {
                menuButton.setAttribute('aria-pressed', 'false');
                siteNav?.classList.remove('nav-open');
                siteSidebar.classList.remove('sidebar-open');
            }
        });
    }

    // kept nav opened
    var firstNavs = document.querySelectorAll('.nav-first');
    var page_path = decodeURI(window.location.pathname).replace(/%20/g, " ");
    page_path = page_path.replace(baseurl, "");
    var page_tree = page_path.split('/');

    Array.prototype.forEach.call(firstNavs, function (nav_first) {
        if (page_tree[1] === nav_first.ariaLabel){
            nav_first.classList.add('active');

            var secondNavs = nav_first.querySelectorAll('.nav-second');

            Array.prototype.forEach.call(secondNavs, function (nav_second) {
                if (page_tree[2] === nav_second.ariaLabel){
                    nav_second.classList.toggle('active');

                    var thirdNavs = nav_second.querySelectorAll('.nav-third');

                    Array.prototype.forEach.call(thirdNavs, function (nav_third) {
                        if (page_tree[3] === nav_third.ariaLabel){
                            nav_third.classList.toggle('active');
                        }
                    });
                }
            });
        }
    });

    // navigation (toogle sub-category)
    document.addEventListener('click', function(e){
        var target = e.target;

        while (target && !(target.classList && target.classList.contains('nav-list-expander'))) {
            target = target.parentNode;
        }

        if (target) {
            e.preventDefault();
            var nav_item = target.parentNode;
            target.ariaPressed = nav_item.parentNode.classList.toggle('active');
        }
    });

    document.querySelectorAll('.nav-item').forEach((nav_item) => {
        if (nav_item.parentNode.classList.contains('active')){
            nav_item.classList.add('selected');
        }
        else {
            nav_item.classList.remove('selected');
        }
    });

    document.querySelectorAll('.category-toggle').forEach(function(toggle) {
        toggle.addEventListener('click', function() {
            var branch = toggle.closest('.category-branch');
            if (!branch) return;

            var isOpen = branch.classList.toggle('is-open');
            toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        });
    });

    // Change Datk/Light Theme
    const themeButton = document.querySelectorAll("#btn-brightness");
    const innerContent = document.querySelector('main');

    themeButton.forEach((btn) => {
        btn.addEventListener('click', function() {
            const moonIcons = document.querySelectorAll(".ico-dark");
            const sunIcons = document.querySelectorAll(".ico-light");
            const codeblocks = innerContent != null ? innerContent.querySelectorAll('pre') : null;

            moonIcons.forEach((ico) => {
                ico.classList.toggle('active');
            });

            sunIcons.forEach((ico) => {
                ico.classList.toggle('active');
            });

            document.body.classList.toggle('dark-theme');

            if (isDarkMode){
                localStorage.setItem('theme', 'default');
                // Disable highlighter dark color theme
                if (codeblocks) {
                    Array.from(codeblocks).forEach(function (codeblock){
                        codeblock.classList.remove('pre-dark');
                    });
                }

                changeGiscusTheme('light');
                isDarkMode = false;
            }
            else {
                localStorage.setItem('theme', 'dark');
                // Disable highlighter default color theme
                if (codeblocks) {
                    Array.from(codeblocks).forEach(function (codeblock){
                        codeblock.classList.add('pre-dark');
                    });
                }

                changeGiscusTheme('noborder_gray');
                isDarkMode = true;
            }

            window.dispatchEvent(new CustomEvent('blog:theme-change', {
                detail: {
                    theme: isDarkMode ? 'dark' : 'default'
                }
            }));
        });
    });

    function changeGiscusTheme(theme) {
        const iframe = document.querySelector('iframe.giscus-frame');
        if (!iframe) return;

        const message = {
            setConfig: {
                theme: theme
            }
        };

        iframe.contentWindow.postMessage({ giscus: message }, 'https://giscus.app');
    }

    // search box
    const searchButton = document.querySelectorAll("#btn-search, .btn-search");
    const sidebarSearchInputs = document.querySelectorAll(".sidebar-search-input");
    const cancelButton = document.querySelector('#btn-clear');
    const searchPage = document.querySelector("#search");
    const searchInput = document.getElementById("search-input");

    function openSearch(value) {
        if (!searchPage || !searchInput) return;

        searchPage.classList.add('active');
        searchPage.setAttribute('aria-hidden', 'false');

        if (typeof value === 'string') {
            searchInput.value = value;
            searchInput.dispatchEvent(new KeyboardEvent('keyup'));
        }

        searchInput.focus();
    }

    if (searchButton) {
        searchButton.forEach((btn) => {
            btn.addEventListener('click', function() {
                openSearch();
            });
        });
    }

    if (sidebarSearchInputs) {
        sidebarSearchInputs.forEach((input) => {
            input.addEventListener('focus', function() {
                openSearch(input.value);
            });

            input.addEventListener('input', function() {
                openSearch(input.value);
            });
        });
    }

    if (searchPage) {
        searchPage.addEventListener('click', function(event) {
            const searchBar = document.querySelector(".search-box");
            var target = event.target;

            if (searchBar.contains(target))
                return;

            searchPage.classList.remove('active');
            searchPage.setAttribute('aria-hidden', 'true');
        });
    }

    if (cancelButton) {
        cancelButton.addEventListener('click', function() {
            document.getElementById('btn-clear').style.display = 'none';
            document.getElementById('search-input').value = "";
            document.getElementById('search-result').style.display = 'none';

            Array.from(document.querySelectorAll('.result-item')).forEach(function (item) {
                item.remove();
            });
        });
    }
});

function searchPost(pages){
    document.getElementById('search-input').addEventListener('keyup', function() {
        var keyword = this.value.toLowerCase();
        var matchedPosts = [];
        const searchResults = document.getElementById('search-result');
        const prevResults = document.querySelector(".result-item");
    
        if (keyword.length > 0) {
            searchResults.style.display = 'block';
            document.getElementById('btn-clear').style.display = 'block';
        } else {
            searchResults.style.display = 'none';
            document.getElementById('btn-clear').style.display = 'none';
        }
        
        Array.from(document.querySelectorAll('.result-item')).forEach(function (item) {
            item.remove();
        });
    
        for (var i = 0; i < pages.length; i++) {
            var post = pages[i];
    
            if (post.title === 'Home' && post.type == 'category') continue;
    
            if (post.title.toLowerCase().indexOf(keyword) >= 0
            || post.path.toLowerCase().indexOf(keyword) >= 0
            || post.tags.toLowerCase().indexOf(keyword) >= 0){
                matchedPosts.push(post);
            }
        }
    
        if (matchedPosts.length === 0) {
            insertItem('<span class="description">검색 결과가 없습니다.</span>');

            return;
        } 
    
        matchedPosts.sort(function (a, b) {
            if (a.type == 'category') return 1;
    
            return -1;
        });
    
        for (var i = 0; i < matchedPosts.length; i++) {
            var highlighted_path = highlightKeyword(matchedPosts[i].path, keyword);
    
            if (highlighted_path === '')
                highlighted_path = "Home";
    
            if (matchedPosts[i].type === 'post'){
                var highlighted_title = highlightKeyword(matchedPosts[i].title, keyword);
                var highlighted_tags = highlightKeyword(matchedPosts[i].tags, keyword);
    
                if (highlighted_tags === '')
                    highlighted_tags = "none";

                insertItem('<a href="' +
                    matchedPosts[i].url +
                    '"><table><thead><tr><th><svg class="ico-book"></svg></th><th>' + highlighted_title +  
                    '</th></tr></thead><tbody><tr><td><svg class="ico-folder"></svg></td><td>' + highlighted_path +
                    '</td></tr><tr><td><svg class="ico-tags"></svg></td><td>' + highlighted_tags +
                    '</td></tr><tr><td><svg class="ico-calendar"></svg></td><td>' + matchedPosts[i].date +
                    '</td></tr></tbody></table></a>'
                );
            }
            else {
                insertItem('<a href="' +
                    matchedPosts[i].url +
                    '"><table><thead><tr><th><svg class="ico-folder"></svg></th><th>' + highlighted_path + 
                    '</th></tr></thead></table></a>'
                );
            }
        }

        function insertItem(inner_html){
            let contents = document.createElement("li");
            contents.classList.add("result-item");
            contents.innerHTML = inner_html;
            searchResults.append(contents);
        }
    });

    function highlightKeyword(txt, keyword) {
        var index = txt.toLowerCase().lastIndexOf(keyword);
    
        if (index >= 0) { 
            out = txt.substring(0, index) + 
                "<span class='highlight'>" + 
                txt.substring(index, index+keyword.length) + 
                "</span>" + 
                txt.substring(index + keyword.length);
            return out;
        }
    
        return txt;
    }
}

function searchRelated(pages){
    const refBox = document.getElementById('related-box');
    const refResults = document.getElementById('related-posts');

    if (!refBox) return;

    var relatedPosts = [];
    var currPost = pages.find(obj => {
        var postPath = new URL(obj.url, location.origin).pathname;
        return postPath === location.pathname;
    });

    if (!currPost) return;

    let currTags = currPost.tags.split(', ');
    let currCategory = currPost.path.split(' > ').pop();

    for (var i = 0; i < pages.length; i++) {
        let page = pages[i];

        if (page.type === 'category') continue;

        if (page.title === currPost.title) continue;

        let tags = page.tags.split(', ');
        let category = page.path.split(' > ').pop();
        let correlationScore = 0;

        for (var j = 0; j < currTags.length; j++){
            if (tags.indexOf(currTags[j]) != -1) correlationScore += 1;
        }

        if (category === currCategory) correlationScore += 1;

        if (correlationScore == 0) continue;

        relatedPosts.push({
            'title': page.title,
            'date': page.date,
            'category': category,
            'keyword': page.keyword,
            'url': page.url,
            'thumbnail': page.image,
            'score': correlationScore
        });
    }

    relatedPosts.sort(function (a, b) {
        if(a.hasOwnProperty('score')){
            return b.score - a.score;
        }
    });

    if (relatedPosts.length == 0){
        refBox.style.display = 'none';
        return;
    }

    function escapeHTML(value) {
        return String(value || '').replace(/[&<>"']/g, function(char) {
            return {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;'
            }[char];
        });
    }

    for (var i = 0; i < Math.min(relatedPosts.length, 3); i++){
        let post = relatedPosts[i];
        let date = '-';
        let category = 'No category';

        if (post.date !== '1900-01-01'){
            date = new Date(post.date);
            date = date.toLocaleString('en-US', {day: 'numeric', month:'long', year:'numeric'});
        }

        if (post.category !== '') category = post.category;

        let keyword = post.keyword || category || post.title;
        let tone = 'tone-' + (i % 4);
        let contents = document.createElement("li");
        contents.classList.add("related-item");
        contents.innerHTML = '<a href="' + post.url +
            '"><span class="related-media ' + tone + 
            '"><span>' + escapeHTML(keyword) + 
            '</span><em>&lt;/&gt;</em></span><div class="related-copy"><p class="category">' + escapeHTML(category) +  
            '</p><p class="title">' + escapeHTML(post.title) + 
            '</p><p class="date">' + escapeHTML(date) +
            '</p></div></a>';

        refResults.append(contents);
    }
}
