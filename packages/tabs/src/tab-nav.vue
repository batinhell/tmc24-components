<script>
  import TabBar from './tab-bar';
  import { addResizeListener, removeResizeListener } from 'tmconsulting-ui/src/utils/resize-event';

  function noop() {}
  const firstUpperCase = str => {
    return str.toLowerCase().replace(/( |^)[a-z]/g, (L) => L.toUpperCase());
  };

  export default {
    name: 'TabNav',

    components: {
      TabBar
    },

    inject: ['rootTabs'],

    props: {
      panes: Array,
      currentName: String,
      editable: Boolean,
      onTabClick: {
        type: Function,
        default: noop
      },
      onTabRemove: {
        type: Function,
        default: noop
      },
      type: String
    },

    data() {
      return {
        scrollable: false,
        navOffset: 0,
        isFocus: false
      };
    },

    computed: {
      navStyle() {
        const dir = ['top', 'bottom'].indexOf(this.rootTabs.tabPosition) !== -1 ? 'X' : 'Y';
        return {
          transform: `translate${dir}(-${this.navOffset}px)`
        };
      },
      sizeName() {
        return ['top', 'bottom'].indexOf(this.rootTabs.tabPosition) !== -1 ? 'width' : 'height';
      }
    },

    methods: {
      scrollPrev() {
        const containerSize = this.$refs.navScroll[`offset${firstUpperCase(this.sizeName)}`];
        const currentOffset = this.navOffset;

        if (!currentOffset) return;

        let newOffset = currentOffset > containerSize
          ? currentOffset - containerSize
          : 0;

        this.navOffset = newOffset;
      },
      scrollNext() {
        const navSize = this.$refs.nav[`offset${firstUpperCase(this.sizeName)}`];
        const containerSize = this.$refs.navScroll[`offset${firstUpperCase(this.sizeName)}`];
        const currentOffset = this.navOffset;

        if (navSize - currentOffset <= containerSize) return;

        let newOffset = navSize - currentOffset > containerSize * 2
          ? currentOffset + containerSize
          : (navSize - containerSize);

        this.navOffset = newOffset;
      },
      scrollToActiveTab() {
        if (!this.scrollable) return;
        const nav = this.$refs.nav;
        const activeTab = this.$el.querySelector('.is-active');
        const navScroll = this.$refs.navScroll;
        const activeTabBounding = activeTab.getBoundingClientRect();
        const navScrollBounding = navScroll.getBoundingClientRect();
        const navBounding = nav.getBoundingClientRect();
        const currentOffset = this.navOffset;
        let newOffset = currentOffset;

        if (activeTabBounding.left < navScrollBounding.left) {
          newOffset = currentOffset - (navScrollBounding.left - activeTabBounding.left);
        }
        if (activeTabBounding.right > navScrollBounding.right) {
          newOffset = currentOffset + activeTabBounding.right - navScrollBounding.right;
        }
        if (navBounding.right < navScrollBounding.right) {
          newOffset = nav.offsetWidth - navScrollBounding.width;
        }
        this.navOffset = Math.max(newOffset, 0);
      },
      update() {
        if (!this.$refs.nav) return;
        const sizeName = this.sizeName;
        const navSize = this.$refs.nav[`offset${firstUpperCase(sizeName)}`];
        const containerSize = this.$refs.navScroll[`offset${firstUpperCase(sizeName)}`];
        const currentOffset = this.navOffset;

        if (containerSize < navSize) {
          const currentOffset = this.navOffset;
          this.scrollable = this.scrollable || {};
          this.scrollable.prev = currentOffset;
          this.scrollable.next = currentOffset + containerSize < navSize;
          if (navSize - currentOffset < containerSize) {
            this.navOffset = navSize - containerSize;
          }
        } else {
          this.scrollable = false;
          if (currentOffset > 0) {
            this.navOffset = 0;
          }
        }
      },
      changeTab(e) {
        const keyCode = e.keyCode;
        let nextIndex;
        let currentIndex, tabList;
        if ([37, 38, 39, 40].indexOf(keyCode) !== -1) { // 左右上下键更换tab
          tabList = e.currentTarget.querySelectorAll('[role=tab]');
          currentIndex = Array.prototype.indexOf.call(tabList, e.target);
        } else {
          return;
        }
        if (keyCode === 37 || keyCode === 38) { // left
          if (currentIndex === 0) { // first
            nextIndex = tabList.length - 1;
          } else {
            nextIndex = currentIndex - 1;
          }
        } else { // right
          if (currentIndex < tabList.length - 1) { // not last
            nextIndex = currentIndex + 1;
          } else {
            nextIndex = 0;
          }
        }
        tabList[nextIndex].focus(); // 改变焦点元素
        tabList[nextIndex].click(); // 选中下一个tab
        this.setFocus();
      },
      setFocus() {
        this.isFocus = true;
      },
      removeFocus() {
        this.isFocus = false;
      }
    },

    updated() {
      this.update();
    },

    render() {
      const {
        type,
        panes,
        editable,
        onTabClick,
        onTabRemove,
        navStyle,
        scrollable,
        scrollNext,
        scrollPrev,
        changeTab,
        setFocus,
        removeFocus
      } = this;
      const scrollBtn = scrollable
        ? [
          <span class={['tm-tabs__nav-prev', scrollable.prev ? '' : 'is-disabled']} on-click={scrollPrev}><i class="tm-icon--arrow-left"></i></span>,
          <span class={['tm-tabs__nav-next', scrollable.next ? '' : 'is-disabled']} on-click={scrollNext}><i class="tm-icon--arrow-right"></i></span>
        ] : null;

      const tabs = this._l(panes, (pane, index) => {
        let tabName = pane.name || pane.index || index;
        const closable = pane.isClosable || editable;

        pane.index = `${index}`;

        const btnClose = closable
          ? <span class="tm-tabs__close" on-click={(ev) => { onTabRemove(pane, ev); }}>
            <tm-icon name="cross-bold"></tm-icon>
          </span>
          : null;

        const icon = pane.icon
          ? <tm-icon name={ pane.icon } class="tm-tabs__icon"></tm-icon>
          : null;

        const label = pane.$slots.label || pane.label;

        const tabLabelContent = label
          ? <div class="tm-tabs__label">{ label }</div>
          : null;
        const tabindex = pane.active ? 0 : -1;
        return (
          <div
            class={{
              'tm-tabs__item': true,
              [`is-${ this.rootTabs.tabPosition }`]: true,
              'is-active': pane.active,
              'is-disabled': pane.disabled,
              'is-closable': closable,
              'is-focus': this.isFocus
            }}
            id={`tab-${tabName}`}
            aria-controls={`pane-${tabName}`}
            role="tab"
            aria-selected={ pane.active }
            ref="tabs"
            tabindex={tabindex}
            refInFor
            on-focus={ ()=> { setFocus(); }}
            on-blur ={ ()=> { removeFocus(); }}
            on-click={(ev) => { removeFocus(); onTabClick(pane, tabName, ev); }}
            on-keydown={(ev) => { if (closable && (ev.keyCode === 46 || ev.keyCode === 8)) { onTabRemove(pane, ev);} }}
          >
            {icon}
            {tabLabelContent}
            {btnClose}
          </div>
        );
      });
      return (
        <div class={['tm-tabs__nav-wrap', scrollable ? 'is-scrollable' : '', `is-${ this.rootTabs.tabPosition }`]}>
          {scrollBtn}
          <div class={['tm-tabs__nav-scroll']} ref="navScroll">
            <div class="tm-tabs__nav" ref="nav" style={navStyle} role="tablist" on-keydown={ changeTab }>
              {!type ? <tab-bar tabs={panes}></tab-bar> : null}
              {tabs}
            </div>
          </div>
        </div>
      );
    },

    mounted() {
      addResizeListener(this.$el, this.update);
    },

    beforeDestroy() {
      if (this.$el && this.update) removeResizeListener(this.$el, this.update);
    }
  };
</script>

