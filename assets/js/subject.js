document.addEventListener('DOMContentLoaded', function(){
    // Loading page
    const hideLoading = () => {
        var load_div = document.querySelector('#loading');

        if(load_div != null){
            setTimeout(function(){
                load_div.style.transition = '.75s';
                load_div.style.opacity = '0';
                load_div.style.visibility = 'hidden';
            }, 800);
        }
    };

    hideLoading();
    window.addEventListener("load", hideLoading);

    // pagination
    const paginationNumbers = document.querySelector("#pagination-numbers");
    const paginatedList = document.querySelector(".paginated-list");

    if (paginatedList) {
        const listItems = paginatedList.querySelectorAll("li");
        const nextButton = document.querySelector("#next-button");
        const prevButton = document.querySelector("#prev-button");
        const pageKey = "pageKey=" + document.URL;
        const viewButtons = document.querySelectorAll(".view-switch [data-view]");
        const viewKey = "feedView=" + document.URL;

        const paginationLimit = 3;
        const pageCount = Math.ceil(listItems.length / paginationLimit);
        let currentPage = 1;

        const setFeedView = (view) => {
            const normalizedView = view === "list" ? "list" : "grid";
            paginatedList.classList.toggle("list-view", normalizedView === "list");

            viewButtons.forEach((button) => {
                const isActive = button.dataset.view === normalizedView;
                button.classList.toggle("active", isActive);
                button.setAttribute("aria-pressed", isActive ? "true" : "false");
            });

            localStorage.setItem(viewKey, normalizedView);
        };

        const disableButton = (button) => {
            button.classList.add("disabled");
            button.setAttribute("disabled", true);
        };
        
        const enableButton = (button) => {
            button.classList.remove("disabled");
            button.removeAttribute("disabled");
        };

        const handlePageButtonsStatus = () => {
            if (currentPage === 1) {
                disableButton(prevButton);
            } else {
                enableButton(prevButton);
            }
        
            if (pageCount === currentPage) {
                disableButton(nextButton);
            } else {
                enableButton(nextButton);
            }
        };

        const handleActivePageNumber = () => {
            document.querySelectorAll(".pagination-number").forEach((button) => {
                button.classList.remove("active");
                
                const pageIndex = Number(button.getAttribute("page-index"));

                if (pageIndex == currentPage) {
                    button.classList.add("active");
                }
            });
        };

        const appendPageNumber = (index) => {
            const pageNumber = document.createElement("button");

            pageNumber.className = "pagination-number";
            pageNumber.innerHTML = index;
            pageNumber.setAttribute("page-index", index);
            pageNumber.setAttribute("aria-label", "Page " + index);

            paginationNumbers.appendChild(pageNumber);
        };

        const getPaginationNumbers = () => {
            for (let i = 1; i <= pageCount; i++) {
                appendPageNumber(i);
            }
        };

        const setCurrentPage = (pageNum) => {
            currentPage = pageNum;
            
            handleActivePageNumber();
            handlePageButtonsStatus();

            const prevRange = (pageNum - 1) * paginationLimit;
            const currRange = pageNum * paginationLimit;

            listItems.forEach((item, index) => {
                item.classList.add("hidden");

                if (index >= prevRange && index < currRange) {
                    item.classList.remove("hidden");
                }
            });

            window.scrollTo({top:0});
            localStorage.setItem(pageKey, currentPage);
        };

        window.addEventListener("load", (event) => {
            // Load last visited page number
            if (event.persisted 
            || (window.performance && window.performance.navigation.type == 2)) {
                currentPage = localStorage.getItem(pageKey);
            }

            getPaginationNumbers();
            setCurrentPage(currentPage);
            setFeedView(localStorage.getItem(viewKey) || "grid");

            viewButtons.forEach((button) => {
                button.addEventListener("click", () => {
                    setFeedView(button.dataset.view);
                });
            });

            prevButton.addEventListener("click", () => {
                setCurrentPage(currentPage - 1);
            });
            
            nextButton.addEventListener("click", () => {
                setCurrentPage(currentPage + 1);
            });

            document.querySelectorAll(".pagination-number").forEach((button) => {
                const pageIndex = Number(button.getAttribute("page-index"));

                if (pageIndex) {
                    button.addEventListener("click", () => {
                        setCurrentPage(pageIndex);
                    });
                }
            });
        });
    }
});
