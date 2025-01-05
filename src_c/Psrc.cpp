/// Jean-Pierre Laroche
/// projet 2018-08-08  (C) 2018   Copyright 2018  <laroche.jeanpierre@gmail.com>
/// but :     terminal rapide    / flexible / respectant le code escape
///            fast / flexible terminal / respecting the escape code
///            -no-pie EXÉCUTABLE  programme maitre mini server terminal
///            plus souple que XTERM et plus sécuritaire que les terminal public  pour des applicatifs
///            outil pour développer une application de type 5250 / 3270 ou terminal semi-graphic
///            tool to develop a 5250/3270 or terminal semi-graphic application


///  GTK3 and X11



#include <filesystem>
#include <sys/stat.h>
#include <vte-2.91/vte/vte.h>
#include <pango/pango.h>
#include <gdk/gdkx.h>

/// si test cout
//#include <iostream>


#define _DEBUG_ 1 /// ALT_F4 ACTIVE

///------------------------------------------
/// paramétrage spécifique
/// ex:
///------------------------------------------

#define WORKPGM        ""

#define MESSAGE_ALT_F4 "vous devez activer uniquement \n en développemnt  \n Confirm destroy Application --> DEBUG"


/// ----------------------------------------
/// par default
///-----------------------------------------
#define VTENAME "VTE-TERM3270"

unsigned int COL=    168;    /// max 132

unsigned int ROW =    44;        /// max 42 including a line for the system

/// Font DejaVu Sans Mono -> xfce4-terminal
/// defined not optional  -> gnome-terminal
#define VTEFONT    "Source Code Pro"

//*******************************************************
// PROGRAME
//*******************************************************



GtkWidget    *window, *terminal;

GPid child_pid = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    function alphanumeric switch
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
constexpr unsigned long long int strswitch(const char* c_name, unsigned long long int l_hash = 0)    /// string to int for switch
{

    return (*c_name == 0) ? l_hash : 101 * strswitch(c_name + 1) + *c_name;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    Contrôle affectation programme
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool ctrlPgm(std::string v_TEXT)
{
    int b_pgm = false;


    std::filesystem::path p(v_TEXT.c_str());
                                            switch(strswitch(p.stem().c_str()))
                                            {
                                                case  strswitch("menuTest")        : b_pgm =true;        break;
                                                case  strswitch("formTest")        : b_pgm =true;        break;
                                            }
    return b_pgm;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///        traitement terminal GTK.
///
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void close_window()
{
    gtk_main_quit ();
}


///-------------------------------------
/// traitement ALT+F4
///-------------------------------------
gboolean key_press_ALTF4()
{

        GtkWidget *dialog;
        const gchar* _MSG_ =  MESSAGE_ALT_F4;

        dialog = gtk_message_dialog_new(
                                        GTK_WINDOW(window),
                                        GTK_DIALOG_MODAL,
                                        GTK_MESSAGE_QUESTION,
                                        GTK_BUTTONS_YES_NO,
                                        _MSG_,
                                        NULL,
                                        NULL);

        int result = gtk_dialog_run (GTK_DIALOG (dialog));

        gtk_widget_destroy(GTK_WIDGET(dialog));

        switch (result)
        {
            case  GTK_RESPONSE_YES:
                                    {
                                        close_window();
                                        return EXIT_FAILURE ;
                                        //break;
                                    }
            case GTK_RESPONSE_NO:
                                    // not active ALT_F4
                                    return GDK_EVENT_STOP;
                                    //break;
        }


    return GDK_EVENT_STOP;
}



/// -----------------------------------------------------------------------------
/// personalisation projet utilisant une terminal simplifier pour de la gestion
/// -----------------------------------------------------------------------------

void    init_Terminal()
{

    VteTerminal *VTE;

    //determines the maximum size for screens
    Display* d = XOpenDisplay(NULL);
    Screen*  s = DefaultScreenOfDisplay(d);
    // obsolète
    //gint width  = gdk_screen_width();
    //gint height = gdk_screen_height();
    char * font_terminal = new char[30] ;


    /// confortable and extend numbers columns and rows

    if ( s->width <= 1600 && s->height >=1024 ) {                    // ex: 13"... 15"
        sprintf(font_terminal,"%s %s" , VTEFONT,"10");
        COL = 168;
        ROW = 44;
        }
    else if ( s->width <= 1920 && s->height >=1080 ) {            // ex: 17"... 32"
        sprintf(font_terminal,"%s %s" , VTEFONT,"12");
        COL = 168;
        ROW = 44;
        }
    else if ( s->width > 1920  ) {                                          //  ex: 2560 x1600 > 27"  font 13
        sprintf(font_terminal,"%s %s" , VTEFONT,"13");        //  ex: 3840 x2160 > 32"  font 15
        COL = 168;
        ROW = 44;
    }
    //COL = 132;
    //ROW = 32;
    // resize  title  font
  VTE = VTE_TERMINAL (terminal);

  vte_terminal_set_font (VTE,pango_font_description_from_string(font_terminal));        /// font utilisé

    vte_terminal_set_size (VTE, COL, ROW);                                                /// size du terminal

    gtk_window_set_title(GTK_WINDOW(window), VTENAME);                                    /// titre du terminal de base

    vte_terminal_set_scrollback_lines (VTE,0);                                             ///    désactiver historique.

    vte_terminal_set_scroll_on_output(VTE,FALSE);                                        /// pas de défilement en cas de nouvelle sortie

    vte_terminal_set_scroll_on_keystroke(VTE,FALSE);                                    /// pas de défilement en bas s’il y a interaction de l’utilisateur

    vte_terminal_set_mouse_autohide(VTE, TRUE);                                            /// cacher le curseur de la souris quand le clavier est utilisé.

    vte_terminal_set_cursor_blink_mode(VTE, VTE_CURSOR_BLINK_ON);                        /// cursor blink on

    vte_terminal_set_cursor_shape(VTE,VTE_CURSOR_SHAPE_BLOCK);                            /// define cursor 'block'



}


/// -----------------------------------------------------------------------------
/// Callback for vte_terminal_spawn_async    retrived PID terminal ONLY
/// -----------------------------------------------------------------------------
void term_spawn_callback(VteTerminal *terminal, GPid pid, GError *error, gpointer user_data)
{
        child_pid = pid;
}
/// -----------------------------------------------------------------------------
/// possibility to change the name of the terminal
/// -----------------------------------------------------------------------------


void on_title_changed(GtkWidget *terminal)
{
    const char *title;
    title = vte_terminal_get_termprop_string_by_id(VTE_TERMINAL(terminal), VTE_PROPERTY_ID_XTERM_TITLE, NULL);
    gtk_window_set_title (GTK_WINDOW(window), title);
}

/// -----------------------------------------------------------------------------
/// possibility to change the number of columns and rows
/// -----------------------------------------------------------------------------

void on_resize_window(GtkWidget *terminal, guint  _col, guint _row)
{
    vte_terminal_set_size (VTE_TERMINAL(terminal),_col,_row);
    gtk_widget_show_all(window);
}





/// -----------------------------------------------------------------------------
///  libvte function putting the terminal function active
/// -----------------------------------------------------------------------------

inline bool exists_File (const std::string& name) {
    struct stat fileStat;
    if(stat(name.c_str(),&fileStat) < 0) return false;      // is exist objet

    stat(name.c_str(),&fileStat);
    if (S_ISDIR(fileStat.st_mode) == 1 ) return false;      // is dir

    if ((fileStat.st_mode & S_IXUSR) == 0 ) return false;     // pas un executable

    return (stat (name.c_str(), &fileStat) == 0);
}


// programme linux pas d'extention windows ".exe"
inline bool extention_File(const std::string& name) {
        std::filesystem::path filePath = name.c_str();
        if (filePath.extension()!= "") return false;
        return true;
}

inline bool isDir_File(const std::string& name) {
        std::string strdir = std::filesystem::path(name.c_str()).parent_path();
        if (strdir.empty() ) return false;
        return true;
}





int main(int argc, char *argv[])
{
    std::setlocale(LC_ALL, "");
    const gchar *dir;
    gchar ** command ;

/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------
/// contrôle autorisation traitement --> protection



    gchar *arg_1[] = { (gchar*)WORKPGM,  NULL};
    gchar *arg_2[] = { (gchar*) argv[1], NULL};        /// arg[1] P_pgm
    // exemple P_Pgm (argv[1]) = ./programme

    if (argc == 1 )  {
        if ( false == ctrlPgm(WORKPGM))                    return EXIT_FAILURE;    // contrôle file autorisation
        if ( false == exists_File(WORKPGM) )             return EXIT_FAILURE;    // contrôle si programme
        dir = std::filesystem::path(WORKPGM).parent_path().c_str();
        command = arg_1;
    }
    if (argc == 2 )  {
        if ( false == ctrlPgm((char*)argv[1]))            return EXIT_FAILURE;    // contrôle file autorisation
        if ( false == extention_File((char*)argv[1]) )    return EXIT_FAILURE;    // contrôle extention
        if ( false == isDir_File((char*)argv[1]) )         return EXIT_FAILURE;     // contrôle is directorie
        if ( false == exists_File((char*)argv[1]) )        return EXIT_FAILURE;    // contrôle si programme
        dir = std::filesystem::path((const char*)(char*)argv[1]).parent_path().c_str();
        command = arg_2;
    }
    if (argc > 2)  return EXIT_FAILURE;




/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------


    // Initialise GTK, the window traditional work

    gtk_init(&argc,&argv);
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    //gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER_ALWAYS);
    gtk_window_set_resizable (GTK_WINDOW(window),false);

    #ifdef _DEBUG_  
        gtk_window_set_deletable (GTK_WINDOW(window),true);
    #else
        gtk_window_set_deletable (GTK_WINDOW(window),false);
    #endif

    /* Initialise the terminal */
    terminal = vte_terminal_new();

    // specific initialization of the terminal
    init_Terminal();


    vte_terminal_spawn_async(
        VTE_TERMINAL(terminal), //VteTerminal *terminal
        VTE_PTY_DEFAULT, // VtePtyFlags pty_flags,

        dir,            // const char *working_directory
        command,        // command

        NULL,            // environment
        (GSpawnFlags)(G_SPAWN_SEARCH_PATH |G_SPAWN_FILE_AND_ARGV_ZERO),                // spawn flags
        NULL,            // GSpawnChildSetupFunc child_setup,
        NULL,            // gpointer child_setup_data,
        NULL,            // GDestroyNotify child_setup_data_destroy,
        -1,                // int timeout
        NULL,            // GCancellable *cancellable,

        &term_spawn_callback,// VteTerminalSpawnAsyncCallback callback, get pid child

        NULL);            // gpointer user_data


    // Connect some signals
    g_signal_connect(GTK_WINDOW(window),"delete_event", G_CALLBACK(key_press_ALTF4), NULL);


    g_signal_connect(terminal, "child-exited",  G_CALLBACK (close_window), NULL);
    g_signal_connect(terminal, "destroy",  G_CALLBACK (close_window), NULL);

    g_signal_connect(terminal, "window-title-changed", G_CALLBACK(on_title_changed), NULL);
    g_signal_connect(terminal, "resize-window", G_CALLBACK(on_resize_window),NULL);


    /* Put widgets together and run the main loop */
    gtk_container_add(GTK_CONTAINER(window), terminal);

    gtk_widget_hide(window);            // hide = ignore flash
    gtk_widget_show_all(window);        // for test invalide contrôle protection

    gtk_main();

    return EXIT_SUCCESS;
}
