import 'dart:io';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_config/flutter_config.dart';
import 'package:image_picker/image_picker.dart';

// var api_key = FlutterConfig.get("GeGEMINI_API_KEY");
// var api_key = 'sdsdsdsd';
var api_key = "AIzaSyAiD9I0FIdoQ1E_3fQGzL4jt5__WNX03_U";

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final Gemini gemini = Gemini.instance;
  String taskst = '';
  dataBase db = dataBase();
  //refer box
  final _box = Hive.box('box1');

  @override
  void initState() {
    if (_box.get('ListData') == null) {
      db.initally();
    } else {
      db.loadTasks();
    }
    super.initState();
  }

//change task status
  void changeTaskStatus(bool? status, int index) {
    setState(() {
      db.tklist[index][1] = !db.tklist[index][1];
      db.updatData(); //change status by inversing the status
    });
  }

  void addTask(String taskst) {
    setState(() {
      String taskName = taskst.trim();
      if (taskName.isNotEmpty) {
        if (taskName.length < 500) {
          db.tklist.add([taskName, false]);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task is too long'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
      db.updatData();
    });
  }

  void edit(String taskst, int index) {
    setState(() {
      String taskName = taskst.trim();
      if (taskName.isNotEmpty) {
        if (taskName.length < 500) {
          db.tklist[index][0] = taskName;
          db.tklist[index][1] = false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task is too long to edit'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        db.tklist.removeAt(index);
      }
      db.updatData();
    });
  }

  void deleteTask(int index) {
    setState(() {
      db.tklist.removeAt(index);
      db.updatData();
    });
  }

  void editTask(int index) {
    setState(() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Task',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 30,
                )),
            backgroundColor: Colors.black,
            content: TextField(
              style: TextStyle(color: Colors.white),
              controller: TextEditingController(text: db.tklist[index][0]),
              onChanged: (value) {
                taskst = value;
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  edit(taskst, index);
                  Navigator.of(context).pop();
                },
                child: Text('Add',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
            ],
          );
        },
      );
    });
  }

  final _chatController = InMemoryChatController();
  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? imageFile;
  bool loading = false;
  List textAndImageChat = [];
  // List textWithImageChat = [];
  List textChat = [];
  final ImagePicker picker = ImagePicker();
  // Create Gemini Instance
  // final gemini = GoogleGemini(
  //   apiKey: api_key,
  //   // model: 'models/gemini-1.5-pro',
  //   model: 'gemini-2.0-flash-lite',
  //   // model: 'models/gemini-2.0-flash',
  // );

  void processChatWithImage(
      {required String query,
      StateSetter? modalSetState,
      required File image}) async {
    setState(() {
      loading = true;
      textAndImageChat.add({
        "role": "You",
        "text": query,
        "image": image,
      });
      _controller.clear();
      imageFile = null;
    });
    if (modalSetState != null) {
      modalSetState(() {});
    }
    scrollToTheEnd();
    try {
      // Build chat history with proper Content format
      List<Content> chatHistory = await _buildChatHistory();

      // Add current message to chat history
      chatHistory.add(Content(
        role: 'user',
        parts: [
          Part.text(query),
          Part.bytes(await image.readAsBytes()),
        ],
      ));
      // print("Chat History: $chatHistory");
      if (modalSetState != null) {
        modalSetState(() {});
      }
      // Send chat with history context
      final response = await gemini.chat(chatHistory);
      print("Response: ${response?.output}");

      setState(() {
        loading = false;
        textAndImageChat.add({
          "role": "Gemini",
          "text": response?.output ?? "No response received",
        });
      });
      if (modalSetState != null) {
        modalSetState(() {});
      }
      scrollToTheEnd();
    } catch (error) {
      setState(() {
        loading = false;
        textAndImageChat
            .add({"role": "Gemini", "text": error.toString(), "image": ""});
      });
      if (modalSetState != null) {
        modalSetState(() {});
      }
      scrollToTheEnd();
    }
    // gemini.generateFromTextAndImages(query: query, image: image).then((value) {
    //   setState(() {
    //     loading = false;
    //     textAndImageChat
    //         .add({"role": "Gemini", "text": value.text, "image": ""});
    //   });
    //   scrollToTheEnd();
    // }).onError((error, stackTrace) {
    //   setState(() {
    //     loading = false;
    //     textAndImageChat
    //         .add({"role": "Gemini", "text": error.toString(), "image": ""});
    //   });
    //   scrollToTheEnd();
    // });
  }

  void processChat({required String query, StateSetter? modalSetState}) async {
    setState(() {
      loading = true;
      textAndImageChat.add({
        "role": "You",
        "text": query,
      });
      _controller.clear();
    });
    if (modalSetState != null) {
      modalSetState(() {});
    }
    try {
      final chatHistory = await _buildChatHistory();
      final response = await gemini.chat(chatHistory);
      // print("Response: ${response?.output}");
      setState(() {
        loading = false;
        textAndImageChat.add({
          "role": "A.I",
          "text": response?.output ?? "No response",
        });
      });
      if (modalSetState != null) {
        modalSetState(() {});
      }
      scrollToTheEnd();

      // gemini.prompt(parts: [
      //   Part.text(query),
      // ]).then((value) {
      //   setState(() {
      //     loading = false;
      //     textAndImageChat.add({
      //       "role": "A.I",
      //       "text": value?.output,
      //     });
      //   });
      //   // Update modal state if available
      //   if (modalSetState != null) {
      //     modalSetState(() {});
      //   }
      //   scrollToTheEnd();
      // }).onError((error, stackTrace) {
      //   print("Error: $error");
      //   setState(() {
      //     loading = false;
      //     textAndImageChat.add({
      //       "role": "A.I",
      //       "text": error.toString(),
      //     });
      //   });
      // Update modal state if available
      //   if (modalSetState != null) {
      //     modalSetState(() {});
      //   }
      //   scrollToTheEnd();
      // });
    } catch (e) {
      print("Exception: $e");
      setState(() {
        loading = false;
        textAndImageChat.add({
          "role": "A.I",
          "text": "An error occurred while processing your request.",
        });
      });
      // Update modal state if available
      if (modalSetState != null) {
        modalSetState(() {});
      }
      scrollToTheEnd();
    }
  }

  Future<List<Content>> _buildChatHistory() async {
    List<Content> chatHistory = [];

    for (var message in textAndImageChat) {
      String role = message["role"] == "You" ? "user" : "model";
      List<Part> parts = [Part.text(message["text"])];

      // Add image if present
      if (message["image"] != null && message["image"] != "") {
        if (message["image"] is File) {
          File imageFile = message["image"] as File;
          parts.add(Part.bytes(await imageFile.readAsBytes()));
        }
      }

      chatHistory.add(Content(
        role: role,
        parts: parts,
      ));
    }

    return chatHistory;
  }

  void scrollToTheEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent +
    //     max(1.0, _scrollController.position.maxScrollExtent * 0.5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text('doList',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 30,
            )),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: db.tklist.isEmpty //check if list is empty conditional
          ? Center(
              child: Text('No Tasks , do something!!',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 20,
                  )),
            )
          : ListView.builder(
              itemCount: db.tklist.length,
              itemBuilder: (context, index) {
                return Tasks(
                  tasksnm: db.tklist[index][0],
                  isDone: db.tklist[index][1],
                  onChanged: (status) {
                    changeTaskStatus(status, index);
                  },
                  deleteTask: (context) {
                    deleteTask(index);
                  },
                  editTask: (context) {
                    editTask(index);
                  },
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 35, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () {
                scrollToTheEnd();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.black,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setModalState) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 14,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: textAndImageChat.length,
                                    itemBuilder: (context, index) {
                                      return textAndImageChat[index]["role"] ==
                                              'A.I'
                                          ? ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              isThreeLine: true,
                                              leading: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.greenAccent,
                                                    width: 2.0,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  child: Text(
                                                    'A.I',
                                                    style: TextStyle(
                                                        color: Colors.cyan),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                textAndImageChat[index]["role"],
                                                style: TextStyle(
                                                  color: Colors.cyanAccent,
                                                ),
                                              ),
                                              subtitle: Text(
                                                textAndImageChat[index]["text"],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              isThreeLine: true,
                                              leading: null,
                                              trailing: textAndImageChat[index]
                                                          .containsKey(
                                                              "image") &&
                                                      textAndImageChat[index]
                                                              ["image"] !=
                                                          null
                                                  ? Image.file(
                                                      textAndImageChat[index]
                                                          ["image"],
                                                      width: 90,
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              Colors.cyanAccent,
                                                          width: 2.0,
                                                        ),
                                                      ),
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.black,
                                                        child: Text(
                                                          'U',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.cyan),
                                                        ),
                                                      ),
                                                    ),
                                              title: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  textAndImageChat[index]
                                                      ["role"],
                                                  style: TextStyle(
                                                    color: Colors.cyanAccent,
                                                  ),
                                                ),
                                              ),
                                              subtitle: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  textAndImageChat[index]
                                                      ["text"],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.only(
                                                  left: 70,
                                                  right: 16,
                                                  top: 8,
                                                  bottom: 8),
                                            );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _controller,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Type your message...',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              borderSide: const BorderSide(
                                                color: Colors.cyanAccent,
                                                width: 2.0,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              borderSide: const BorderSide(
                                                color: Colors.cyanAccent,
                                                width: 2.0,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              borderSide: const BorderSide(
                                                color: Colors.cyanAccent,
                                                width: 2.0,
                                              ),
                                            ),
                                            prefixIcon: IconButton(
                                              icon: const Icon(
                                                Icons.image,
                                                color: Colors.cyanAccent,
                                              ),
                                              onPressed: () async {
                                                final XFile? image =
                                                    await picker.pickImage(
                                                  source: ImageSource.gallery,
                                                );
                                                if (image != null) {
                                                  imageFile = File(image.path);
                                                  setState(() {});
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: loading
                                            ? const CircularProgressIndicator()
                                            : const Icon(Icons.send),
                                        onPressed: () {
                                          if (_controller.text.isNotEmpty) {
                                            if (imageFile != null) {
                                              processChatWithImage(
                                                  query: _controller.text,
                                                  modalSetState: setModalState,
                                                  image: imageFile!);
                                            } else {
                                              processChat(
                                                query: _controller.text,
                                                modalSetState: setModalState,
                                              );
                                            }
                                            _controller.clear();
                                            scrollToTheEnd();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            //  Chat(
                            //   chatController: _chatController,
                            //   currentUserId: 'user',
                            //   onMessageSend: (text) {
                            //     _chatController.insertMessage(
                            //       TextMessage(
                            //         id: DateTime.now()
                            //             .millisecondsSinceEpoch
                            //             .toString(),
                            //         authorId: 'user',
                            //         createdAt: DateTime.now().toUtc(),
                            //         text: text,
                            //       ),
                            //     );
                            //   },
                            //   resolveUser: (UserID id) async {
                            //     return User(id: '10');
                            //   },
                            // ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              backgroundColor: Colors.cyanAccent,
              child: Icon(
                Icons.auto_awesome,
              ),
            ),
            FloatingActionButton(
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add Task',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 30,
                          )),
                      backgroundColor: Colors.black,
                      content: TextField(
                        maxLines: taskst.isEmpty ? 1 : null,
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          taskst = value;
                        },
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            addTask(taskst);
                            Navigator.of(context).pop();
                          },
                          child: Text('Add',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              )),
                        ),
                      ],
                    );
                  },
                ),
              },
              backgroundColor: Colors.cyanAccent,
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
