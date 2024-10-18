/// -----------------------------------------------------------------
/// Jean-Pierre Laroche
/// projet 2018-08-08  (C) 2018   Copyright 2018  <laroche.jeanpierre@gmail.com>
/// but : 	
///			fast / flexible terminal / respecting the escape code
///			-no-pie EXÉCUTABLE  programme server terminal
///			More flexible than XTERM and more secure than public terminals
///			tool to develop a 5250/3270 or terminal semi-graphic application





#include <filesystem>
#include <sys/stat.h>
#include <vte-2.91/vte/vte.h>
#include <pango/pango.h>
#include <gdk/gdkx.h>

///------------------------------------------
/// paramétrage spécifique
/// ex:
///------------------------------------------

/// #define _ALTF4_ 1 /// ALT_F4 ACTIVE


#define WORKPGM		"/home/soleil/.helix/hx"



#define MESSAGE_ALT_F4 "Confirm destroy Application"


/// ----------------------------------------
/// par default
///-----------------------------------------
#define VTENAME "VTE-TERM3270"

/// basic function
unsigned int COL=	80;		
unsigned int ROW =	24;

/// defined not optional police default
#define VTEFONT	"Source code Pro"

//*******************************************************
// PROGRAME
//*******************************************************



GtkWidget	*window, *terminal;

GPid child_pid = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	function alphanumeric switch
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
constexpr unsigned long long int strswitch(const char* c_name, unsigned long long int l_hash = 0)	/// string to int for switch
{

	return (*c_name == 0) ? l_hash : 101 * strswitch(c_name + 1) + *c_name;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Contrôle affectation programme
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool ctrlPgm(std::string v_TEXT)
{
	int b_pgm = false;


	std::filesystem::path p(v_TEXT.c_str());
											switch(strswitch(p.stem().c_str()))
											{
						case  strswitch("hx")		: b_pgm =true;		break;
											}
	return b_pgm;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///		traitement terminal GTK.
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

	// not active ALT_F4
	return GDK_EVENT_STOP;
}

///-------------------------------------
/// traitement CTRL-Z
///-------------------------------------
gboolean key_press_CTRLZ(GtkWidget *widget, GdkEventKey *event)
{

	( void ) widget;
	if ( event->state & ( GDK_CONTROL_MASK ) )
	{
		if ( event->keyval == GDK_KEY_z ||  event->keyval == GDK_KEY_Z )
		{
			return GDK_EVENT_STOP;
		}

        if ( event->keyval == GDK_3BUTTON_PRESS )
		{
			return GDK_EVENT_STOP;
		}
	}
	return false ;
}

///-------------------------------------
/// traitement clipboard
///-------------------------------------
//gboolean clipboard(GtkWidget *widget)
//{
//	return false;
//}
/// -----------------------------------------------------------------------------
/// personalisation projet utilisant une terminal simplifier pour de la gestion
/// -----------------------------------------------------------------------------

void	init_Terminal()
{

	VteTerminal *VTE;

	char * font_terminal = new char[30] ;

	/// confortable and extend numbers columns and rows
	// HELIX 
	sprintf(font_terminal,"%s %s" , VTEFONT," 14"); 
	COL = 125; // 120 cols  src
	ROW = 44;  // 42  lines src


	// resize  title  font
	VTE = VTE_TERMINAL (terminal);

	vte_terminal_set_font (VTE,pango_font_description_from_string(font_terminal));		/// font use

	vte_terminal_set_size (VTE, COL, ROW);												/// size du terminal

	vte_terminal_set_scrollback_lines (VTE,0);		 									///	désactiver historique.

	vte_terminal_set_scroll_on_output(VTE,FALSE);										/// pas de défilement 

	vte_terminal_set_scroll_on_keystroke(VTE,FALSE);									/// pas de défilement 

	vte_terminal_set_mouse_autohide(VTE, TRUE);											/// hiden  mouse  keyboard Actif .

	vte_terminal_set_cursor_blink_mode(VTE, VTE_CURSOR_BLINK_ON);						/// cursor blink on

	vte_terminal_set_cursor_shape(VTE,VTE_CURSOR_SHAPE_BLOCK);							/// define cursor 'block'


}


/// -----------------------------------------------------------------------------
/// Callback for vte_terminal_spawn_async	retrived PID terminal ONLY
/// -----------------------------------------------------------------------------
void term_spawn_callback(VteTerminal *terminal, GPid pid, GError *error, gpointer user_data)
{
		child_pid = pid;
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
	if(stat(name.c_str(),&fileStat) < 0) return false;  	// is exist objet

	stat(name.c_str(),&fileStat);
	if (S_ISDIR(fileStat.st_mode) == 1 ) return false;  	// is dir

	if ((fileStat.st_mode & S_IXUSR) == 0 ) return false; 	// pas un executable

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
    gchar *arg_1[]  = { (gchar*)WORKPGM,  NULL}; // hx 
    gchar *arg_2[] = { (gchar*)WORKPGM,(char*)"-c", (gchar*) argv[3], NULL}; // hx file
	gchar ** command ;
    
	gchar  *Title = (char*) malloc (200);;
	sprintf(Title,"Project: %s",(gchar*) argv[1]); // PROJECT

	const gchar *dir = (gchar*) argv[2];  // parm lib work parm file





/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------
/// 4 argument  
/// 0= le programe TermHX
/// 1= Project
/// 2= directory working
/// 3= file option 66 
/// contrôle autorisation traitement --> protection
/// BUTTON CLOSE off
/// ALT-F4 CLOSE windows HX
/// Button mini / maxi ON

	if ( false == ctrlPgm(WORKPGM))					return EXIT_FAILURE;	// contrôle file exist helix
//printf(" nbr argc %d", argc);
    
	if (argc >4 || argc < 3 )  return EXIT_FAILURE;
	if (argc == 3) {
        command = arg_1;
    }
	if (argc == 4) {
		command = arg_2;

	};

/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------
/// -----------------------------------------------------------------------------


	// Initialise GTK, the window traditional work

	gtk_init(&argc,&argv);
	window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

	gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);

	gtk_window_set_resizable (GTK_WINDOW(window),true);			   // <--- spécifique helix
	
    #ifdef _ALTF4_  
        gtk_window_set_deletable (GTK_WINDOW(window),true);
    #else
        gtk_window_set_deletable (GTK_WINDOW(window),false);
    #endif


	gtk_widget_set_events ( window, GDK_KEY_PRESS_MASK );

	/* Initialise the terminal */
	terminal = vte_terminal_new();

	// specific initialization of the terminal
	init_Terminal();


	vte_terminal_spawn_async(
		VTE_TERMINAL(terminal), //VteTerminal *terminal
		VTE_PTY_DEFAULT, // VtePtyFlags pty_flags,

		dir,			// const char *working_directory PROJECT ex; $home/myproject/src-zig
		command,		// command

		NULL,			// environment
		(GSpawnFlags)(G_SPAWN_SEARCH_PATH |G_SPAWN_FILE_AND_ARGV_ZERO),				// spawn flags
		NULL,			// GSpawnChildSetupFunc child_setup,
		NULL,			// gpointer child_setup_data,
		NULL,			// GDestroyNotify child_setup_data_destroy,
		-1,				// int timeout
		NULL,			// GCancellable *cancellable,

		&term_spawn_callback,// VteTerminalSpawnAsyncCallback callback, get pid child

		NULL);			// gpointer user_data


	gtk_window_set_title(GTK_WINDOW(window),Title);  // name PROJECT

	// Connect some signals
	g_signal_connect(GTK_WINDOW(window),"delete_event", G_CALLBACK(key_press_ALTF4), NULL);
	g_signal_connect(G_OBJECT(window),"key_press_event", G_CALLBACK(key_press_CTRLZ), NULL);

	g_signal_connect(terminal, "child-exited",  G_CALLBACK (close_window), NULL);
	g_signal_connect(terminal, "destroy",  G_CALLBACK (close_window), NULL);

	g_signal_connect(terminal, "resize-window", G_CALLBACK(on_resize_window),NULL);




	/* Put widgets together and run the main loop */
	gtk_container_add(GTK_CONTAINER(window), terminal);

	gtk_widget_hide(window);			// hide = ignore flash
	gtk_widget_show_all(window);		// run

	gtk_main();

	return EXIT_SUCCESS;
}
