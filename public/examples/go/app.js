// Generated by CoffeeScript 1.4.0

T.def('main', function() {
  return ['.gvreset.gameviewer', T('banner').process(), T('board').process(), T('toolbar').process(), T('point-label').process(), T('right-panel').process(), T('go-to').process()];
});

T.def('banner', function() {
  return [
    '.gvreset.gvbanner.BANNER', ['.gvreset.gvbanner-overlay.BANNER_BACKGROUND'], [
      '.gvreset.gvbanner-left', T('language-switcher').process(), '&nbsp;&nbsp;', t('whose_turn'), "&nbsp;", [
        'img.gvreset.nextPlayerImg.NEXT_PLAYER', {
          src: 'images/default.gif'
        }
      ]
    ], T('move-number').process(), T('resign').process(), ['.gvreset.gvbanner-overlay', T('banner-prisoners').process(), T('window-opener').process()]
  ];
});

T.def('language-switcher', function() {
  return [
    [
      'a.gvreset.localization', {
        href: 'javascript: void(jsGameViewer.GV1.changeLocale("zh_cn"))'
      }, '中文'
    ], ' | ', [
      'a.gvreset.localization', {
        href: 'javascript: void(jsGameViewer.GV1.changeLocale("en_us"))'
      }, 'EN'
    ]
  ];
});

T.def('move-number', function() {
  return [
    '.gvreset.gvmove-outer.gvbutton.MOVE_OUTER', [
      'a.gvreset.thickbox', {
        href: '#TB_inline?test=0&width=250&height=56&inlineId=GV1_goTo&focus=GV1_goToInput&modal=true&test1=0',
        title: "" + (t('jump_to_xx')) + " [Alt Shift G]"
      }, t('move_number_before'), '&nbsp;', ['span.gvreset.gvcontrol-text.CURRENT_MOVE', 0], '&nbsp;', t('move_number_after')
    ]
  ];
});

T.def('resign', function() {
  return [
    '.gvreset.gvresign.RESIGN', [
      'span.gvreset.gvbutton', [
        'a', {
          href: 'javascript: void(jsGameViewer.GV1.resign())'
        }, t('resign')
      ]
    ]
  ];
});

T.def('banner-prisoners', function() {
  return ['.gvreset.gvprisoners-outer', T('banner-prisoner', 'black'), T('banner-prisoner', 'white')];
});

T.def('banner-prisoner', function(color) {
  return [
    ".gvreset.gv" + color + "-prisoners-outer", [
      "span.gvreset.gvbutton." + color + "_PRISONERS_OUTER", [
        'a', {
          href: 'javascript: void(0)'
        }, [
          'img.gvreset.prisonersImg', {
            src: "images/15/" + color + "_dead.gif"
          }, '&nbsp;', ["span.gvreset.gvcontrol-text." + color + "_PRISONERS", 0]
        ]
      ]
    ]
  ];
});

T.def('window-opener', function() {
  return [
    'gvreset.gvopen-window-outer', [
      'a', {
        title: "" + (t('open_in_new_window')) + " [Alt Shift W]",
        href: 'javascript: void(jsGameViewer.GV1.openInWindow())'
      }, [
        'img.gvreset.gvsprite-newwindow', {
          src: 'images/default.gif'
        }
      ]
    ]
  ];
});

T.def('board', function() {
  return [
    '.gvreset.gvboard-outer.gvsprite-21-board', [
      '.gvreset.gvboard', ['.gvreset.gvboard-overlay.BOARD_POINTS'], ['.gvreset.gvboard-overlay.BOARD_MARKS'], ['.gvreset.gvboard-overlay.BOARD_BRANCHES'], ['.gvreset.gvsprite-21-markmove.MOVE_MARKS'], ['.gvreset.gvboard-overlay.PRISONERS'], [
        '.gvreset.gvboard-overlay.gvboardfascade.BOARD_FASCADE', [
          'img.gvreset.gvsprite-21-blankboard', {
            src: 'images/default.gif'
          }
        ]
      ]
    ]
  ];
});

T.def('toolbar', function() {
  return [
    '.gvreset.gvtoolbar.TOOLBAR', [
      '.gvreset.gvtb-item.REFRESH', [
        'a.gvreset.toggleopacity', {
          href: "javascript: void(jsGameViewer.GV1.refresh(true))",
          title: "" + (t('refresh')) + " [Alt Shift R]"
        }, [
          'img.gvreset.gvsprite-refresh.REFRESH_IMG', {
            src: 'images/default.gif'
          }
        ]
      ]
    ], [
      '.gvreset.gvtb-item.TOGGLE_NUMBER', [
        'a.gvreset.toggleopacity', {
          href: "javascript: void(jsGameViewer.GV1.toggleNumber())",
          title: "" + (t('refresh')) + " [Alt Shift R]"
        }, [
          'img.gvreset.gvsprite-refresh.TOGGLE_NUMBER_IMG', {
            src: 'images/shownumber.gif'
          }
        ]
      ]
    ]
  ];
});

T.def('point-label', function() {
  return [
    '.gvreset.gvpoint-label.POINT_LABEL', {
      style: {
        'text-align': 'center'
      }
    }
  ];
});

T.def('right-panel', function() {
  return ['.gvreset.gvright-pane.RIGHT_PANEL', ['.gvreset.gvinfo.INFO'], ['.gvreset.gvcomment.COMMENT']];
});

T.def('go-to', function() {
  return [
    '.GO_TO', {
      style: {
        display: 'none'
      }
    }, [
      'form', {
        name: 'GV1_goToForm',
        action: '#',
        onsubmit: 'return false'
      }, t('jump_to'), [
        'input.GO_TO_INPUT', {
          name: 'goToInput',
          size: 5,
          type: 'text',
          onkeydown: 'jsGameViewer.GV1.goToKeyDown(this,event)',
          style: {
            'text-align': 'center'
          }
        }
      ], t('move_number_after'), '&nbsp;&nbsp;&nbsp;&nbsp;', [
        'input', {
          type: 'submit',
          value: t('submit'),
          onclick: 'jsGameViewer.GV1.goToOkHandler();'
        }
      ], '&nbsp;&nbsp;', [
        'input', {
          type: 'submit',
          value: t('cancel'),
          onclick: 'tb_remove();jsGameViewer.GV1.postThickBoxFix();'
        }
      ]
    ]
  ];
});

$('#container').html(T('main').render());
