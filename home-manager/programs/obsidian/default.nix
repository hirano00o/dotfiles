{ config, pkgs, ... }:
let
  plugins = import ./plugins.nix { inherit pkgs; };
in
{
  programs.obsidian = {
    enable = true;

    # Common settings applied to all vaults.
    # Vault-level settings override these when explicitly set.
    defaultSettings = {
      # Generates ~/.obsidian/app.json
      app = {
        vimMode = true;
        promptDelete = false;
        alwaysUpdateLinks = true;
      };

      # Generates ~/.obsidian/appearance.json
      appearance = {
        accentColor = "";
      };

      # Generates ~/.obsidian/core-plugins.json
      # Only plugins defined in home-manager's corePluginsList are managed here.
      # "webviewer", "footnotes" are not in the list yet, so they are omitted.
      corePlugins = [
        "file-explorer"
        "global-search"
        "switcher"
        "graph"
        "backlink"
        "canvas"
        "outgoing-link"
        "tag-pane"
        "page-preview"
        "daily-notes"
        {
          name = "templates";
          # Generates ~/.obsidian/templates.json
          settings = {
            folder = "templates";
          };
        }
        "note-composer"
        "command-palette"
        "editor-status"
        "bookmarks"
        "outline"
        "word-count"
        "slides"
        "file-recovery"
        "bases"
        {
          name = "properties";
          enable = false;
        }
        {
          name = "slash-command";
          enable = false;
        }
        {
          name = "markdown-importer";
          enable = false;
        }
        {
          name = "zk-prefixer";
          enable = false;
        }
        {
          name = "random-note";
          enable = false;
        }
        {
          name = "audio-recorder";
          enable = false;
        }
        {
          name = "workspaces";
          enable = false;
        }
        {
          name = "publish";
          enable = false;
        }
        {
          name = "sync";
          enable = false;
        }
      ];

      # Community plugins shared across all vaults.
      # home-manager automatically generates:
      #   - community-plugins.json  (enabled plugin ID list from manifest.json)
      #   - plugins/<id>/           (symlinks to $out/* via recursive = true)
      #   - plugins/<id>/data.json  (settings, when the settings attribute is set)
      communityPlugins = [
        plugins.checklistPlugin
        plugins.cmEditorSyntaxHighlight
        {
          pkg = plugins.advancedUri;
          settings = {
            openFileOnWrite = true;
            openDailyInNewPane = true;
            openFileOnWriteInNewPane = true;
            openFileWithoutWriteInNewPane = false;
            idField = "id";
            useUID = false;
            addFilepathWhenUsingUID = false;
            allowEval = false;
            includeVaultName = true;
            vaultParam = "name";
          };
        }
        {
          pkg = plugins.excalidrawPlugin;
          settings = {
            disableDoubleClickTextEditing = false;
            folder = "Excalidraw";
            cropFolder = "";
            annotateFolder = "";
            embedUseExcalidrawFolder = false;
            templateFilePath = "Excalidraw/Template.excalidraw";
            scriptFolderPath = "Excalidraw/Scripts";
            fontAssetsPath = "Excalidraw/CJK Fonts";
            loadChineseFonts = false;
            loadJapaneseFonts = false;
            loadKoreanFonts = false;
            compress = true;
            decompressForMDView = false;
            onceOffCompressFlagReset = true;
            onceOffGPTVersionReset = true;
            autosave = true;
            autosaveIntervalDesktop = 15000;
            autosaveIntervalMobile = 10000;
            drawingFilenamePrefix = "Drawing ";
            drawingEmbedPrefixWithFilename = true;
            drawingFilnameEmbedPostfix = " ";
            drawingFilenameDateTime = "YYYY-MM-DD HH.mm.ss";
            useExcalidrawExtension = true;
            cropSuffix = "";
            cropPrefix = "cropped_";
            annotateSuffix = "";
            annotatePrefix = "annotated_";
            annotatePreserveSize = false;
            previewImageType = "SVGIMG";
            renderingConcurrency = 3;
            allowImageCache = true;
            allowImageCacheInScene = true;
            displayExportedImageIfAvailable = false;
            previewMatchObsidianTheme = false;
            width = "400";
            height = "";
            overrideObsidianFontSize = false;
            dynamicStyling = "colorful";
            isLeftHanded = false;
            desktopUIMode = "tray";
            tabletUIMode = "compact";
            iframeMatchExcalidrawTheme = true;
            matchTheme = false;
            matchThemeAlways = false;
            matchThemeTrigger = false;
            defaultMode = "normal";
            defaultPenMode = "never";
            penModeDoubleTapEraser = true;
            penModeSingleFingerPanning = true;
            penModeCrosshairVisible = true;
            panWithRightMouseButton = false;
            renderImageInMarkdownReadingMode = false;
            renderImageInHoverPreviewForMDNotes = false;
            renderImageInMarkdownToPDF = false;
            allowPinchZoom = false;
            allowWheelZoom = false;
            zoomToFitOnOpen = true;
            zoomToFitOnResize = true;
            zoomToFitMaxLevel = 2;
            zoomStep = 0.05;
            zoomMin = 0.1;
            zoomMax = 30;
            linkPrefix = "📍";
            urlPrefix = "🌐";
            parseTODO = false;
            todo = "☐";
            done = "🗹";
            hoverPreviewWithoutCTRL = false;
            linkOpacity = 1;
            openInAdjacentPane = false;
            showSecondOrderLinks = true;
            focusOnFileTab = false;
            openInMainWorkspace = true;
            showLinkBrackets = true;
            allowCtrlClick = true;
            forceWrap = false;
            pageTransclusionCharLimit = 200;
            wordWrappingDefault = 0;
            removeTransclusionQuoteSigns = true;
            iframelyAllowed = true;
            pngExportScale = 1;
            exportWithTheme = true;
            exportWithBackground = true;
            exportPaddingSVG = 10;
            exportEmbedScene = false;
            keepInSync = false;
            autoexportSVG = false;
            autoexportPNG = false;
            autoExportLightAndDark = false;
            autoexportExcalidraw = false;
            embedType = "excalidraw";
            embedMarkdownCommentLinks = true;
            embedWikiLink = true;
            syncExcalidraw = false;
            experimentalFileType = false;
            experimentalFileTag = "✏️";
            experimentalLivePreview = true;
            fadeOutExcalidrawMarkup = false;
            loadPropertySuggestions = true;
            experimentalEnableFourthFont = false;
            experimantalFourthFont = "Virgil";
            addDummyTextElement = false;
            zoteroCompatibility = false;
            fieldSuggester = true;
            compatibilityMode = false;
            drawingOpenCount = 0;
            library = "deprecated";
            library2 = {
              type = "excalidrawlib";
              version = 2;
              source = "https://github.com/zsviczian/obsidian-excalidraw-plugin/releases/tag/2.17.2";
              libraryItems = [ ];
            };
            imageElementNotice = true;
            mdSVGwidth = 500;
            mdSVGmaxHeight = 800;
            mdFont = "Virgil";
            mdFontColor = "Black";
            mdBorderColor = "Black";
            mdCSS = "";
            scriptEngineSettings = { };
            previousRelease = "2.17.2";
            showReleaseNotes = true;
            compareManifestToPluginVersion = true;
            showNewVersionNotification = true;
            latexBoilerplate = "\\color{blue}";
            latexPreambleLocation = "preamble.sty";
            taskboneEnabled = false;
            taskboneAPIkey = "";
            pinnedScripts = [ ];
            customPens = [
              {
                type = "default";
                freedrawOnly = false;
                strokeColor = "#000000";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 0;
                roughness = 0;
                penOptions = {
                  highlighter = false;
                  constantPressure = false;
                  hasOutline = false;
                  outlineWidth = 1;
                  options = {
                    thinning = 0.6;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "easeOutSine";
                    start = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                    end = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "highlighter";
                freedrawOnly = true;
                strokeColor = "#FFC47C";
                backgroundColor = "#FFC47C";
                fillStyle = "solid";
                strokeWidth = 2;
                roughness = null;
                penOptions = {
                  highlighter = true;
                  constantPressure = true;
                  hasOutline = true;
                  outlineWidth = 4;
                  options = {
                    thinning = 1;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "linear";
                    start = {
                      taper = 0;
                      cap = true;
                      easing = "linear";
                    };
                    end = {
                      taper = 0;
                      cap = true;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "finetip";
                freedrawOnly = false;
                strokeColor = "#3E6F8D";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 0.5;
                roughness = 0;
                penOptions = {
                  highlighter = false;
                  hasOutline = false;
                  outlineWidth = 1;
                  constantPressure = true;
                  options = {
                    smoothing = 0.4;
                    thinning = -0.5;
                    streamline = 0.4;
                    easing = "linear";
                    start = {
                      taper = 5;
                      cap = false;
                      easing = "linear";
                    };
                    end = {
                      taper = 5;
                      cap = false;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "fountain";
                freedrawOnly = false;
                strokeColor = "#000000";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 2;
                roughness = 0;
                penOptions = {
                  highlighter = false;
                  constantPressure = false;
                  hasOutline = false;
                  outlineWidth = 1;
                  options = {
                    smoothing = 0.2;
                    thinning = 0.6;
                    streamline = 0.2;
                    easing = "easeInOutSine";
                    start = {
                      taper = 150;
                      cap = true;
                      easing = "linear";
                    };
                    end = {
                      taper = 1;
                      cap = true;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "marker";
                freedrawOnly = true;
                strokeColor = "#B83E3E";
                backgroundColor = "#FF7C7C";
                fillStyle = "dashed";
                strokeWidth = 2;
                roughness = 3;
                penOptions = {
                  highlighter = false;
                  constantPressure = true;
                  hasOutline = true;
                  outlineWidth = 4;
                  options = {
                    thinning = 1;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "linear";
                    start = {
                      taper = 0;
                      cap = true;
                      easing = "linear";
                    };
                    end = {
                      taper = 0;
                      cap = true;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "thick-thin";
                freedrawOnly = true;
                strokeColor = "#CECDCC";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 0;
                roughness = null;
                penOptions = {
                  highlighter = true;
                  constantPressure = true;
                  hasOutline = false;
                  outlineWidth = 1;
                  options = {
                    thinning = 1;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "linear";
                    start = {
                      taper = 0;
                      cap = true;
                      easing = "linear";
                    };
                    end = {
                      cap = true;
                      taper = true;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "thin-thick-thin";
                freedrawOnly = true;
                strokeColor = "#CECDCC";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 0;
                roughness = null;
                penOptions = {
                  highlighter = true;
                  constantPressure = true;
                  hasOutline = false;
                  outlineWidth = 1;
                  options = {
                    thinning = 1;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "linear";
                    start = {
                      cap = true;
                      taper = true;
                      easing = "linear";
                    };
                    end = {
                      cap = true;
                      taper = true;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "default";
                freedrawOnly = false;
                strokeColor = "#000000";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 0;
                roughness = 0;
                penOptions = {
                  highlighter = false;
                  constantPressure = false;
                  hasOutline = false;
                  outlineWidth = 1;
                  options = {
                    thinning = 0.6;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "easeOutSine";
                    start = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                    end = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "default";
                freedrawOnly = false;
                strokeColor = "#000000";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 0;
                roughness = 0;
                penOptions = {
                  highlighter = false;
                  constantPressure = false;
                  hasOutline = false;
                  outlineWidth = 1;
                  options = {
                    thinning = 0.6;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "easeOutSine";
                    start = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                    end = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                  };
                };
              }
              {
                type = "default";
                freedrawOnly = false;
                strokeColor = "#000000";
                backgroundColor = "transparent";
                fillStyle = "hachure";
                strokeWidth = 0;
                roughness = 0;
                penOptions = {
                  highlighter = false;
                  constantPressure = false;
                  hasOutline = false;
                  outlineWidth = 1;
                  options = {
                    thinning = 0.6;
                    smoothing = 0.5;
                    streamline = 0.5;
                    easing = "easeOutSine";
                    start = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                    end = {
                      cap = true;
                      taper = 0;
                      easing = "linear";
                    };
                  };
                };
              }
            ];
            numberOfCustomPens = 0;
            pdfScale = 4;
            pdfBorderBox = true;
            pdfFrame = false;
            pdfGapSize = 20;
            pdfGroupPages = false;
            pdfLockAfterImport = true;
            pdfNumColumns = 1;
            pdfNumRows = 1;
            pdfDirection = "right";
            pdfImportScale = 0.3;
            gridSettings = {
              DYNAMIC_COLOR = true;
              COLOR = "#000000";
              OPACITY = 50;
            };
            laserSettings = {
              DECAY_LENGTH = 50;
              DECAY_TIME = 1000;
              COLOR = "#ff0000";
            };
            embeddableMarkdownDefaults = {
              useObsidianDefaults = false;
              backgroundMatchCanvas = false;
              backgroundMatchElement = true;
              backgroundColor = "#fff";
              backgroundOpacity = 60;
              borderMatchElement = true;
              borderColor = "#fff";
              borderOpacity = 0;
              filenameVisible = false;
            };
            markdownNodeOneClickEditing = false;
            canvasImmersiveEmbed = true;
            startupScriptPath = "";
            aiEnabled = true;
            openAIAPIToken = "";
            openAIDefaultTextModel = "gpt-3.5-turbo-1106";
            openAIDefaultTextModelMaxTokens = 4096;
            openAIDefaultVisionModel = "gpt-4o";
            openAIDefaultImageGenerationModel = "dall-e-3";
            openAIURL = "https://api.openai.com/v1/chat/completions";
            openAIImageGenerationURL = "https://api.openai.com/v1/images/generations";
            openAIImageEditsURL = "https://api.openai.com/v1/images/edits";
            openAIImageVariationURL = "https://api.openai.com/v1/images/variations";
            modifierKeyConfig = {
              Mac = {
                LocalFileDragAction = {
                  defaultAction = "image-import";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-import";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "link";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-url";
                    }
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "embeddable";
                    }
                  ];
                };
                WebBrowserDragAction = {
                  defaultAction = "image-url";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-url";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "link";
                    }
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "embeddable";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-import";
                    }
                  ];
                };
                InternalDragAction = {
                  defaultAction = "link";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "link";
                    }
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = true;
                      result = "embeddable";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = true;
                      result = "image-fullsize";
                    }
                  ];
                };
                LinkClickAction = {
                  defaultAction = "new-tab";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "active-pane";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "new-tab";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "new-pane";
                    }
                    {
                      shift = true;
                      ctrl_cmd = true;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "popout-window";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = true;
                      result = "md-properties";
                    }
                  ];
                };
              };
              Win = {
                LocalFileDragAction = {
                  defaultAction = "image-import";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-import";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "link";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-url";
                    }
                    {
                      shift = true;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "embeddable";
                    }
                  ];
                };
                WebBrowserDragAction = {
                  defaultAction = "image-url";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-url";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "link";
                    }
                    {
                      shift = true;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "embeddable";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image-import";
                    }
                  ];
                };
                InternalDragAction = {
                  defaultAction = "link";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "link";
                    }
                    {
                      shift = true;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "embeddable";
                    }
                    {
                      shift = true;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "image";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "image-fullsize";
                    }
                  ];
                };
                LinkClickAction = {
                  defaultAction = "new-tab";
                  rules = [
                    {
                      shift = false;
                      ctrl_cmd = false;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "active-pane";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = false;
                      result = "new-tab";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "new-pane";
                    }
                    {
                      shift = true;
                      ctrl_cmd = true;
                      alt_opt = true;
                      meta_ctrl = false;
                      result = "popout-window";
                    }
                    {
                      shift = false;
                      ctrl_cmd = true;
                      alt_opt = false;
                      meta_ctrl = true;
                      result = "md-properties";
                    }
                  ];
                };
              };
            };
            slidingPanesSupport = false;
            areaZoomLimit = 1;
            longPressDesktop = 500;
            longPressMobile = 500;
            doubleClickLinkOpenViewMode = true;
            isDebugMode = false;
            rank = "Bronze";
            modifierKeyOverrides = [
              {
                modifiers = [ "Mod" ];
                key = "Enter";
              }
              {
                modifiers = [ "Mod" ];
                key = "k";
              }
              {
                modifiers = [ "Mod" ];
                key = "G";
              }
            ];
            showSplashscreen = true;
            pdfSettings = {
              pageSize = "A4";
              pageOrientation = "portrait";
              fitToPage = 1;
              paperColor = "white";
              customPaperColor = "#ffffff";
              alignment = "center";
              margin = "normal";
            };
            disableContextMenu = false;
            defaultTrayMode = false;
            compactModeOnTablets = true;
            autosaveInterval = 15000;
          };
        }
        {
          pkg = plugins.kanban;
          settings = {
            full-list-lane-width = true;
            new-note-folder = "backlogs/tasks";
            tag-action = "kanban";
            tag-colors = [ ];
            show-checkboxes = true;
            move-tags = true;
            move-dates = true;
            date-picker-week-start = 0;
            new-note-template = "backlogs/tasks/template.md";
            date-colors = [
              {
                distance = 1;
                unit = "days";
                direction = "after";
                isBefore = true;
                backgroundColor = "rgba(255, 0, 55, 0.42)";
                color = "rgba(204, 204, 204, 1)";
              }
              {
                isToday = false;
                distance = 7;
                unit = "days";
                direction = "after";
                backgroundColor = "rgba(9, 232, 9, 0.23)";
                color = "rgba(204, 204, 204, 1)";
              }
              {
                distance = 1;
                unit = "days";
                direction = "after";
                isToday = true;
                backgroundColor = "rgba(231, 228, 85, 0.83)";
                color = "rgba(51, 51, 51, 1)";
              }
            ];
          };
        }
        {
          pkg = plugins.terminal;
          settings = {
            addToCommand = true;
            addToContextMenu = true;
            createInstanceNearExistingOnes = true;
            errorNoticeTimeout = 0;
            exposeInternalModules = true;
            focusOnNewInstance = true;
            hideStatusBar = "focused";
            interceptLogging = true;
            language = "";
            newInstanceBehavior = "newHorizontalSplit";
            noticeTimeout = 5;
            openChangelogOnUpdate = true;
            pinNewInstance = true;
            preferredRenderer = "webgl";
            profiles = {
              darwinExternalDefault = {
                args = [ "\"$PWD\"" ];
                executable = "/System/Applications/Utilities/Terminal.app/Contents/macOS/Terminal";
                name = "";
                platforms = {
                  darwin = true;
                };
                restoreHistory = false;
                rightClickAction = "copyPaste";
                successExitCodes = [
                  "0"
                  "SIGINT"
                  "SIGTERM"
                ];
                terminalOptions = {
                  documentOverride = null;
                };
                type = "external";
              };
              darwinIntegratedDefault = {
                args = [ "-l" ];
                executable = "/bin/zsh";
                name = "";
                platforms = {
                  darwin = true;
                };
                pythonExecutable = "python3";
                restoreHistory = false;
                rightClickAction = "copyPaste";
                successExitCodes = [
                  "0"
                  "SIGINT"
                  "SIGTERM"
                ];
                terminalOptions = {
                  documentOverride = null;
                };
                type = "integrated";
                useWin32Conhost = true;
              };
              developerConsole = {
                name = "";
                restoreHistory = false;
                rightClickAction = "copyPaste";
                successExitCodes = [
                  "0"
                  "SIGINT"
                  "SIGTERM"
                ];
                terminalOptions = {
                  documentOverride = null;
                };
                type = "developerConsole";
              };
              linuxExternalDefault = {
                args = [ ];
                executable = "xterm";
                name = "";
                platforms = {
                  linux = true;
                };
                restoreHistory = false;
                rightClickAction = "copyPaste";
                successExitCodes = [
                  "0"
                  "SIGINT"
                  "SIGTERM"
                ];
                terminalOptions = {
                  documentOverride = null;
                };
                type = "external";
              };
              linuxIntegratedDefault = {
                args = [ ];
                executable = "/bin/sh";
                name = "";
                platforms = {
                  linux = true;
                };
                pythonExecutable = "python3";
                restoreHistory = false;
                rightClickAction = "copyPaste";
                successExitCodes = [
                  "0"
                  "SIGINT"
                  "SIGTERM"
                ];
                terminalOptions = {
                  documentOverride = null;
                };
                type = "integrated";
                useWin32Conhost = true;
              };
              win32ExternalDefault = {
                args = [ ];
                executable = "C:\\Windows\\System32\\cmd.exe";
                name = "";
                platforms = {
                  win32 = true;
                };
                restoreHistory = false;
                rightClickAction = "copyPaste";
                successExitCodes = [
                  "0"
                  "SIGINT"
                  "SIGTERM"
                ];
                terminalOptions = {
                  documentOverride = null;
                };
                type = "external";
              };
              win32IntegratedDefault = {
                args = [ ];
                executable = "C:\\Windows\\System32\\cmd.exe";
                name = "";
                platforms = {
                  win32 = true;
                };
                pythonExecutable = "python3";
                restoreHistory = false;
                rightClickAction = "copyPaste";
                successExitCodes = [
                  "0"
                  "SIGINT"
                  "SIGTERM"
                ];
                terminalOptions = {
                  documentOverride = null;
                };
                type = "integrated";
                useWin32Conhost = true;
              };
            };
          };
        }
      ];

      # Files that cannot be managed via dedicated options.
      extraFiles = {
        # Graph view settings
        "graph.json".text = builtins.toJSON {
          collapse-filter = true;
          search = "";
          showTags = false;
          showAttachments = false;
          hideUnresolved = false;
          showOrphans = true;
          collapse-color-groups = true;
          colorGroups = [ ];
          collapse-display = true;
          showArrow = false;
          textFadeMultiplier = 0;
          nodeSizeMultiplier = 1;
          lineSizeMultiplier = 1;
          collapse-forces = true;
          centerStrength = 0.518713248970312;
          repelStrength = 10;
          linkStrength = 1;
          linkDistance = 250;
          scale = 1;
          close = true;
        };

        # Custom property type definitions
        "types.json".text = builtins.toJSON {
          types = {
            aliases = "aliases";
            cssclasses = "multitext";
            tags = "tags";
            excalidraw-plugin = "text";
            excalidraw-export-transparent = "checkbox";
            excalidraw-mask = "checkbox";
            excalidraw-export-dark = "checkbox";
            excalidraw-export-padding = "number";
            excalidraw-export-pngscale = "number";
            excalidraw-export-embed-scene = "checkbox";
            excalidraw-link-prefix = "text";
            excalidraw-url-prefix = "text";
            excalidraw-link-brackets = "checkbox";
            excalidraw-onload-script = "text";
            excalidraw-linkbutton-opacity = "number";
            excalidraw-default-mode = "text";
            excalidraw-font = "text";
            excalidraw-font-color = "text";
            excalidraw-border-color = "text";
            excalidraw-css = "text";
            excalidraw-autoexport = "text";
            excalidraw-embeddable-theme = "text";
            excalidraw-open-md = "checkbox";
            excalidraw-embed-md = "checkbox";
          };
        };

        # Core plugin migration state (mirrors core-plugins.json for legacy compatibility)
        "core-plugins-migration.json".text = builtins.toJSON {
          file-explorer = true;
          global-search = true;
          switcher = true;
          graph = true;
          backlink = true;
          canvas = true;
          outgoing-link = true;
          tag-pane = true;
          properties = false;
          page-preview = true;
          daily-notes = true;
          templates = true;
          note-composer = true;
          command-palette = true;
          slash-command = false;
          editor-status = true;
          bookmarks = true;
          markdown-importer = false;
          zk-prefixer = false;
          random-note = false;
          outline = true;
          word-count = true;
          slides = true;
          audio-recorder = false;
          workspaces = false;
          file-recovery = true;
          publish = false;
          sync = false;
        };
      };
    };

    vaults."vaults/private" = {
      settings = {
        # Vault-specific community plugins added on top of defaultSettings.communityPlugins.
        # Because vault settings override (not merge) defaultSettings, we explicitly
        # concatenate the default list here.
        communityPlugins = config.programs.obsidian.defaultSettings.communityPlugins ++ [
          # remotely-save plugin: sync credentials are managed via sops; data.json is
          # generated through sops.templates below.
          plugins.remotelySave
          plugins.noteArchiver
          # hatena plugin: apiKey is managed via sops; data.json is generated through
          # sops.templates and referenced from extraFiles below.
          plugins.hatena
          {
            pkg = plugins.dataview;
            settings = {
              renderNullAs = "\\-";
              taskCompletionTracking = true;
              taskCompletionUseEmojiShorthand = false;
              taskCompletionText = "completion";
              taskCompletionDateFormat = "yyyy-MM-dd";
              recursiveSubTaskCompletion = true;
              warnOnEmptyResult = true;
              refreshEnabled = true;
              refreshInterval = 2500;
              defaultDateFormat = "yyyy/MM/dd";
              defaultDateTimeFormat = "h:mm a - MMMM dd, yyyy";
              maxRecursiveRenderDepth = 4;
              tableIdColumnName = "File";
              tableGroupColumnName = "Group";
              showResultCount = true;
              allowHtml = true;
              inlineQueryPrefix = "=";
              inlineJsQueryPrefix = "$=";
              inlineQueriesInCodeblocks = true;
              enableInlineDataview = true;
              enableDataviewJs = true;
              enableInlineDataviewJs = true;
              prettyRenderInlineFields = true;
              prettyRenderInlineFieldsInLivePreview = true;
              dataviewJsKeyword = "dataviewjs";
            };
          }
        ];
      };
    };
  };

  # sops templates inject secrets into plugin data.json files at activation time.
  # Each template writes directly to the vault's plugins/<id>/data.json path,
  # bypassing the need for extraFiles source references (which require the file to
  # exist at Nix evaluation time).
  sops.templates = {
    # hatena plugin: apiKey is read from obsidian/plugin/hatena/apiKey secret.
    "obsidian-hatena-data" = {
      path = "${config.home.homeDirectory}/vaults/private/.obsidian/plugins/hatena/data.json";
      mode = "0644";
      content = builtins.toJSON {
        apiKey = config.sops.placeholder."obsidian/plugin/hatena/apiKey";
        rootEndpoint = "https://blog.hatena.ne.jp/hirano00o/hirano00o.hateblo.jp/atom";
      };
    };

    # remotely-save plugin: "d" field holds encrypted sync credentials.
    "obsidian-remotely-save-data" = {
      path = "${config.home.homeDirectory}/vaults/private/.obsidian/plugins/remotely-save/data.json";
      mode = "0644";
      content = builtins.toJSON {
        readme = "The file contains sensitive info, so DO NOT take screenshot of, copy, or share it to anyone! It's also generated automatically, so do not edit it manually.";
        d = config.sops.placeholder."obsidian/plugin/remotely_save/secret";
      };
    };
  };
}
