document.addEventListener('DOMContentLoaded', function(){
    const articleContent = document.querySelector('.post-content');
    const tocBoard = document.querySelector('.toc-board');
    let currentTheme = localStorage.getItem('theme');

    if (articleContent && tocBoard) {
        let headings = Array.from(articleContent.querySelectorAll('h2, h3'));

        if (headings.length === 0) {
            headings = Array.from(articleContent.querySelectorAll('h1, h2'));
        }

        buildHeadingIndexes(headings);
        buildToc(headings, tocBoard);
        observeActiveHeading(headings, tocBoard);
    }

    const links = articleContent ? articleContent.querySelectorAll('a:not(.related-item a)') : [];

    links.forEach((link) => {
        link.setAttribute('data-content', link.innerText);
    });

    const searchPage = document.querySelector("#search");

    document.querySelectorAll('.tag-box .tag').forEach(function(tagButton){
        tagButton.addEventListener('click', function() {
            const contentID = tagButton.getAttribute('contentID');
            const inputBox = document.getElementById('search-input');

            if (!searchPage || !inputBox) return;

            searchPage.classList.add('active');
            searchPage.setAttribute('aria-hidden', 'false');
            inputBox.value = contentID;
            inputBox.dispatchEvent(new KeyboardEvent('keyup'));
            inputBox.focus();
        });
    });

    const arrowButton = document.querySelector('.top-arrow');

    if (arrowButton) {
        setInterval(function(){
            var scrollPos = document.documentElement.scrollTop;

            if (scrollPos < 512){
                arrowButton.classList.remove('arrow-open');
            }
            else {
                arrowButton.classList.add('arrow-open');
            }
        }, 500);

        arrowButton.addEventListener('click', function(){
            window.scroll({top:0, behavior:'smooth'});
        });
    }

    const commentsCounter = document.getElementById('comments-counter');
    const giscusBox = document.getElementById('giscus');

    if (commentsCounter && giscusBox) {
        commentsCounter.addEventListener('click', function(){
            giscusBox.scrollIntoView({
                behavior: 'smooth'
            });
        });
    }

    if (currentTheme === 'dark' && articleContent){
        Array.from(articleContent.querySelectorAll('pre')).forEach(function (codeblock){
            codeblock.classList.add('pre-dark');
        });
    }
});

function buildHeadingIndexes(headings) {
    if (headings.length === 0) return;

    const topLevel = headings[0].tagName;
    const usedIds = {};
    let sectionCount = 0;
    let subSectionCount = 0;

    headings.forEach(function(heading) {
        const isTopLevel = heading.tagName === topLevel;

        if (isTopLevel) {
            sectionCount += 1;
            subSectionCount = 0;
        }
        else {
            if (sectionCount === 0) sectionCount = 1;
            subSectionCount += 1;
        }

        const index = isTopLevel
            ? String(sectionCount).padStart(2, '0')
            : String(sectionCount).padStart(2, '0') + '.' + subSectionCount;

        heading.classList.add('section-heading', 'level-' + heading.tagName.toLowerCase());
        heading.setAttribute('data-heading-index', index);

        if (!heading.id) {
            heading.id = uniqueSlug(heading.textContent, usedIds);
        }
    });
}

function buildToc(headings, tocBoard) {
    tocBoard.innerHTML = '';
    if (headings.length === 0) return;

    const topLevel = headings[0].tagName;
    let currentTopItem;

    headings.forEach(function(heading) {
        let tocItem = document.createElement("li");
        tocItem.classList.add("toc-list-item");

        let itemLink = document.createElement("a");
        itemLink.classList.add("toc-link", "node-name--" + heading.tagName);
        itemLink.id = "toc-id-" + heading.id;
        itemLink.href = "#" + heading.id;
        itemLink.textContent = heading.getAttribute('data-heading-index') + ". " + heading.textContent;

        tocItem.append(itemLink);

        itemLink.addEventListener('click', function(event){
            event.preventDefault();
            heading.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
            history.replaceState(null, '', '#' + heading.id);
        });

        if (heading.tagName === topLevel) {
            currentTopItem = tocItem;
            tocBoard.append(tocItem);
        }
        else {
            if (!currentTopItem) {
                tocBoard.append(tocItem);
                return;
            }

            let subList = currentTopItem.querySelector('ol');

            if (!subList) {
                subList = document.createElement("ol");
                subList.classList.add("toc-list");
                currentTopItem.append(subList);
            }

            subList.append(tocItem);
        }
    });
}

function observeActiveHeading(headings, tocBoard) {
    if (headings.length === 0) return;

    const activate = function(activeHeading) {
        Array.from(tocBoard.querySelectorAll('.toc-link')).forEach(function(link){
            link.classList.remove('is-active-link');
        });

        const tocLink = document.getElementById("toc-id-" + activeHeading.id);
        if (tocLink) tocLink.classList.add('is-active-link');
    };

    if ('IntersectionObserver' in window) {
        const observer = new IntersectionObserver(function(entries) {
            const visible = entries
                .filter(entry => entry.isIntersecting)
                .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);

            if (visible[0]) activate(visible[0].target);
        }, {
            rootMargin: '-18% 0px -70% 0px',
            threshold: 0
        });

        headings.forEach(heading => observer.observe(heading));
        activate(headings[0]);
        return;
    }

    setInterval(function(){
        var scrollPos = document.documentElement.scrollTop;
        var currHead;

        headings.forEach(function(heading){
            let headPos = heading.getBoundingClientRect().top + window.scrollY - 160;
            if (scrollPos > headPos) currHead = heading;
        });

        if (currHead) activate(currHead);
    }, 200);
}

function uniqueSlug(text, usedIds) {
    let slug = text
        .trim()
        .toLowerCase()
        .replace(/[^\w\u3131-\uD79D\s-]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-');

    if (slug === '') slug = 'section';

    let nextSlug = slug;
    let count = 2;

    while (usedIds[nextSlug] || document.getElementById(nextSlug)) {
        nextSlug = slug + '-' + count;
        count += 1;
    }

    usedIds[nextSlug] = true;
    return nextSlug;
}

window.addEventListener('load', function(){
    const pageHits = document.getElementById('page-hits');

    if (pageHits) {
        const goatcounterCode = pageHits.getAttribute('usercode');
        const requestURL = 'https://' 
            + goatcounterCode 
            + '.goatcounter.com/counter/' 
            + encodeURIComponent(location.pathname) 
            + '.json';

        var resp = new XMLHttpRequest();
        resp.open('GET', requestURL);
        resp.onerror = function() { pageHits.innerText = "0"; };
        resp.onload = function() { pageHits.innerText = JSON.parse(this.responseText).count; };
        resp.send();
    }

    if (window.hljs) {
        hljs.highlightAll();

        document.querySelectorAll('.language-text, .language-plaintext').forEach(function(codeblock){
            codeblock.querySelectorAll('.hljs-keyword, .hljs-meta, .hljs-selector-tag').forEach(function($){
                $.outerHTML = $.innerHTML;
            });
        });
    }

    const giscusRepo = document.querySelector('meta[name="giscus_repo"]');
    const giscusRepoId = document.querySelector('meta[name="giscus_repoId"]');
    const giscusCategory = document.querySelector('meta[name="giscus_category"]');
    const giscusCategoryId = document.querySelector('meta[name="giscus_categoryId"]');

    if (giscusRepo && giscusRepo.content) {
        let giscusTheme = "light";
        let currentTheme = localStorage.getItem('theme');

        if (currentTheme === 'dark'){
            giscusTheme = "noborder_gray";
        }

        let giscusAttributes = {
            "src": "https://giscus.app/client.js",
            "data-repo": giscusRepo.content,
            "data-repo-id": giscusRepoId.content,
            "data-category": giscusCategory.content,
            "data-category-id": giscusCategoryId.content,
            "data-mapping": "pathname",
            "data-reactions-enabled": "1",
            "data-emit-metadata": "1",
            "data-theme": giscusTheme,
            "data-lang": "en",
            "crossorigin": "anonymous",
            "async": "",
        };

        let giscusScript = document.createElement("script");
        Object.entries(giscusAttributes).forEach(([key, value]) => giscusScript.setAttribute(key, value));
        document.body.appendChild(giscusScript);
    }

    async function copyCode(block) {
        let code = block.querySelector("code");
        let text = code.innerText;

        if (navigator.clipboard) {
            try {
                await navigator.clipboard.writeText(text);
                return true;
            }
            catch (error) {
                // Fall back below for browser contexts that block Clipboard API.
            }
        }

        let textArea = document.createElement('textarea');
        textArea.value = text;
        textArea.setAttribute('readonly', '');
        textArea.style.position = 'fixed';
        textArea.style.top = '-9999px';
        document.body.appendChild(textArea);
        textArea.select();

        let copied = document.execCommand('copy');
        textArea.remove();
        return copied;
    }

    function showCopySuccess(button) {
        button.classList.add('is-copied');
        button.setAttribute('title', "Copied");
        button.setAttribute('aria-label', "Copied");

        if (button.copyResetTimer) {
            clearTimeout(button.copyResetTimer);
        }

        button.copyResetTimer = setTimeout(function() {
            button.classList.remove('is-copied');
            button.setAttribute('title', "Copy Code");
            button.setAttribute('aria-label', "Copy Code");
            button.copyResetTimer = null;
        }, 1200);
    }

    let blocks = document.querySelectorAll("pre");

    blocks.forEach((block) => {
        if (navigator.clipboard) {
            let clipBtn = document.createElement("button");
            let clipImg = document.createElement("svg");

            clipBtn.setAttribute('title', "Copy Code");
            clipBtn.setAttribute('aria-label', "Copy Code");
            clipBtn.setAttribute('type', "button");
            clipImg.ariaHidden = true;

            block.appendChild(clipBtn);
            clipBtn.appendChild(clipImg);

            clipBtn.addEventListener("click", async () => {
                if (await copyCode(block)) {
                    showCopySuccess(clipBtn);
                }
            });
        }
    });

    function handleMessage(event) {
        if (event.origin !== 'https://giscus.app') return;
        if (!(typeof event.data === 'object' && event.data.giscus)) return;

        const giscusData = event.data.giscus;
        const commentCount = document.getElementById('num-comments');

        if (!commentCount) return;

        if (giscusData && giscusData.hasOwnProperty('discussion')) {
            commentCount.innerText = giscusData.discussion.totalCommentCount;
        }
        else {
            commentCount.innerText = '0';
        }
    }

    window.addEventListener('message', handleMessage);
});
