<style>
  .page-changelog {
    padding-bottom: 100px;

    .fr {
      float: right;
      padding: 0;

      &.tm-button {
        transform: translateY(-3px);
      }

      a {
        display: block;
        padding: 10px 15px;
        color: #333;
      }

      &:hover a {
        color: #409EFF;
      }
    }

    .delimiter {
      background: #ddd;
      width: 100%;
      height: 1px;
      margin: 20px 0 30px;
    }

    .heading {
      font-size: 24px;
      margin-bottom: 60px;
      color: #333;
    }

    .info {
      color: #a5a5a9;
      font-style: italic;
    }

    .timeline {
      padding: 0;
      padding-bottom: 10px;
      position: relative;
      color: #5e6d82;

      > li {
        position: relative;
        padding-bottom: 15px;
        list-style: none;
        line-height: 1.8;
        border: 1px solid #ddd;
        border-radius: 4px;

        &:not(:last-child) {
          margin-bottom: 50px;
        }
      }

      ul {
        padding: 30px 30px 15px;

        ul {
          padding: 0;
          padding-top: 5px;
          padding-left: 27px;

          li {
            padding-left: 0;
            color: #555;
            word-break: normal;
          }

          li::before {
            content: '';
            circle: 4px #fff;
            border: solid 1px #333;
            margin-right: -12px;
            display: inline-block;
            vertical-align: middle;
          }
        }
      }

      li li {
        font-size: 16px;
        list-style: none;
        padding-left: 20px;
        padding-bottom: 5px;
        color: #333;
        word-break: break-all;

        &:before {
          content: '';
          circle: 6px #333;
          transform: translateX(-20px);
          display: inline-block;
          vertical-align: middle;
        }
      }
  
      i {
        padding: 0 20px;
        display: inline-block;
      }

      h3 {
        margin:0;
        padding: 15px 30px;
        border-bottom: 1px solid #ddd;
        font-size: 20px;
        color: #333;
        font-weight: bold;

        a {
          opacity: 1;
          font-size: 20px;
          float: none;
          margin-left: 0;
          color: #333;
        }
      }

      h4 {
        margin: 0;
        margin-bottom: -10px;
        font-size: 18px;
        padding-left: 54px;
        padding-top: 30px;
        font-weight: bold;
      }

      p {
        margin: 0;
        em {
          font-size: 16px;
          color: #666;
          margin: 15px 35px 0;
          display: block;
        }
      }
    }
  }
</style>
<template>
  <div class="page-changelog">
    <div class="heading">
      <tm-button class="fr">
        <a href="https://github.com/tmconsulting/tmc24-components/releases" target="_blank">GitHub Releases</a>
      </tm-button>
      <%= 1 >
    </div>
    <ul class="timeline" ref="timeline">
    </ul>
    <change-log ref="changeLog"></change-log>
    <div class="delimiter"></div>
    <div class="heading">
      <tm-button class="fr">
        <a href="https://github.com/ElemeFE/element/releases" target="_blank">GitHub Releases</a>
      </tm-button>
      ElementUI Changelog (till 2.1.0)
    </div>
    <div class="info">
      TM-Ui is based on ElementUI component library.
      <br>You can read the latest changelog of version we use (2.1.0).
    </div>
    <ul class="timeline" ref="elementTimeline"></ul>
    <element-change-log ref="elementChangeLog"></element-change-log>
  </div>
</template>
<script>
  import ChangeLog from '../../../CHANGELOG.md';
  import ElementChangeLog from '../../../CHANGELOG.ElementUI.md';

  export default {
    components: {
      ChangeLog,
      ElementChangeLog
    },
    data() {
      return {
        count: 3
      };
    },
    mounted() {
      this.renderChangeLog(this.$refs.changeLog, this.$refs.timeline);
      this.renderChangeLog(this.$refs.elementChangeLog, this.$refs.elementTimeline);
    },
    methods: {
      renderChangeLog(changeLog, timeline) {
        const changeLogNodes = changeLog.$el.children;
        let a = changeLogNodes[1].querySelector('a');
        a && a.remove();
        let release = changeLogNodes[1].textContent.trim();
        let fragments = `<li><h3><a href="https://github.com/ElemeFE/element/releases/tag/v${release}" target="_blank">${release}</a></h3>`;

        for (let len = changeLogNodes.length, i = 2; i < len; i++) {
          let node = changeLogNodes[i];
          a = changeLogNodes[i].querySelector('a');
          a && a.getAttribute('class') === 'header-anchor' && a.remove();
          if (node.tagName !== 'H3') {
            fragments += changeLogNodes[i].outerHTML;
          } else {
            release = changeLogNodes[i].textContent.trim();
            fragments += `</li><li><h3><a href="https://github.com/ElemeFE/element/releases/tag/v${release}" target="_blank">${release}</a></h3>`;
          }
        }
        fragments = fragments.replace(/#(\d+)/g, '<a href="https://github.com/ElemeFE/element/issues/$1" target="_blank">#$1</a>');
        fragments = fragments.replace(/@(\w+)/g, '<a href="https://github.com/$1" target="_blank">@$1</a>');
        timeline.innerHTML = `${fragments}</li>`;

        changeLog.$el.remove();
      }
    }
  };
</script>
