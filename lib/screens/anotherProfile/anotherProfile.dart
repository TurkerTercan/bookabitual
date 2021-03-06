import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookabitual/keys.dart';
import 'package:bookabitual/models/book.dart';
import 'package:bookabitual/screens/book/bookpage.dart';
import 'package:bookabitual/screens/profile/listOfUsers.dart';
import 'package:bookabitual/service/database.dart';
import 'package:bookabitual/utils/avatarPictures.dart';
import 'package:bookabitual/widgets/ProjectContainer.dart';
import 'package:bookabitual/widgets/QuotePost.dart';
import 'package:bookabitual/widgets/reviewPost.dart';
import 'package:bookabitual/widgets/smallPostQuote.dart';
import 'package:bookabitual/widgets/smallPostReview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bookworm.dart';
import '../../states/currentUser.dart';

class AnotherProfilePage extends StatefulWidget {
  final Bookworm user;

  const AnotherProfilePage({Key key, @required this.user}) : super(key: key);

  @override
  AnotherProfilePageState createState() => AnotherProfilePageState();
}

class AnotherProfilePageState extends State<AnotherProfilePage> {
  TextEditingController _nameController = TextEditingController();
  Bookworm currentUser;
  int currentIndex;
  final List postList = <Widget>[];
  final Map<Widget, bool> postMap = {};
  List<Widget> reviewPosts = <Widget>[];
  List<Widget> quotePosts = <Widget>[];
  final List boolList = [];
  final List<Book> libraryBooks = [];
  bool status = false;

  Future profileFuture;

  final GlobalKey<RefreshIndicatorState> _globalKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    profileFuture = getAllPosts(currentUser.uid);
    var temp = currentBookworm.following[currentUser.uid];
    if (temp != null)
      status = false;
    else
      status = true;
  }

  void triggerFuture() {
    setState(() {
      profileFuture = getAllPosts(currentUser.uid);
    });
  }

  getAllPosts(String uid) async {
    postList.clear();
    reviewPosts.clear();
    quotePosts.clear();
    boolList.clear();
    postMap.clear();
    QuerySnapshot queryQuoteSnapshot = await BookDatabase().getUserQuotes(uid);
    QuerySnapshot queryReviewSnapshot = await BookDatabase().getUserReviews(uid);


    //List unsorted = [];
    reviewPosts = queryReviewSnapshot.docs.map((documentSnapshot)  {
      ReviewPost reviewPost = ReviewPost(
        isbn: documentSnapshot.data()["isbn"],
        uid: documentSnapshot.data()["uid"],
        postID: documentSnapshot.data()["postID"],
        createTime: documentSnapshot.data()["createTime"],
        likes: documentSnapshot.data()["likes"],
        rating: documentSnapshot.data()["rating"],
        status: documentSnapshot.data()["status"],
        text: documentSnapshot.data()["text"],
        comments: documentSnapshot.data()["comments"],
        trigger: triggerFuture,
      );
      boolList.add(true);
      return reviewPost;
    }).toList();

    await Future.forEach(reviewPosts, (element) async {
      await element.updateInfo();
    });

    postList.addAll(reviewPosts);

    quotePosts = queryQuoteSnapshot.docs.map((documentSnapshot) {
      QuotePost quotePost = QuotePost(
        isbn: documentSnapshot.data()["isbn"],
        uid: documentSnapshot.data()["uid"],
        postID: documentSnapshot.data()["postID"],
        createTime: documentSnapshot.data()["createTime"],
        likes: documentSnapshot.data()["likes"],
        status: documentSnapshot.data()["status"],
        text: documentSnapshot.data()["text"],
        comments: documentSnapshot.data()["comments"],
        trigger: triggerFuture,
      );
      boolList.add(false);
      return quotePost;
    }).toList();

    await Future.forEach(quotePosts, (element) async {
      await element.updateInfo();
    });

    postList.addAll(quotePosts);

    for (int i = 0; i < postList.length; i++) {
      Timestamp a = postList[i].createTime;
      for (int j = 0 ; j < postList.length; j++) {
        Timestamp b = postList[j].createTime;
        if (b.compareTo(a) < 0) {
          var temp1 = postList[i];
          var temp2 = boolList[i];

          postList[i] = postList[j];
          postList[j] = temp1;

          boolList[i] = boolList[j];
          boolList[j] = temp2;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = currentUser.name;
    currentIndex = currentUser.photoIndex;

    ScrollController _scrollController = new ScrollController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text("bookabitual",
          style: TextStyle(
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).bottomAppBarColor,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 1.1,
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ProjectContainer(
                        child: Column(
                          children: [
                            Center(
                              child: CircleAvatar(
                                backgroundImage:
                                AssetImage(avatars[currentUser.photoIndex]),
                                radius: 40.0,
                              ),
                            ),
                            Divider(
                              height: 7,
                              color: Colors.green[100],
                            ),
                            Text(
                              currentUser.name,
                              key: Key(Keys.AnotherProfileUsername),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black,
                                  letterSpacing: 1.0,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold),
                            ),
                            Divider(
                              height: 5,
                              color: Colors.green[100],
                            ),
                            Text(
                              currentUser.username,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black45,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 12,
                      color: Colors.green[100],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BookPage(book: currentUser.currentBook,)));
                        },
                        child: AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: currentUser.currentBookName != "" ? 'I am reading ' : "",
                                style: TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.grey[600],
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              TextSpan(
                                text: currentUser.currentBookName != "" ? currentUser.currentBook.bookTitle : "",
                                style: TextStyle(
                                    fontSize: 22.0,
                                    color: Colors.grey[850],
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          minFontSize: 15,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.green[100],
                      thickness: 0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          child: TextButton(
                            onPressed: () {
                              List<String> uids = currentUser.followers.keys.toList();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ListOfUsers(uids: uids, title: "Followers",)));
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  Text(
                                    currentUser.followers.length.toString(),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Followers",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: TextButton(
                            onPressed: () {
                              List<String> uids = currentUser.following.keys.toList();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ListOfUsers(uids: uids, title: "Following",)));
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  Text(
                                    currentUser.following.length.toString(),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Following",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: Scaffold(
                          appBar: TabBar(
                            isScrollable: true,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            unselectedLabelStyle:
                            TextStyle(fontSize: 18.0, color: Colors.grey),
                            indicator: UnderlineTabIndicator(
                              borderSide:
                              BorderSide(width: 2.0, color: Colors.blueGrey),
                            ),
                            tabs: [
                              Tab(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: Text("Posts"),
                                  ),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.43,
                                  child: Center(
                                    child: Text("Library"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          body: TabBarView(
                            children: [
                              Container(
                                child: ListView(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                                      child: FutureBuilder(
                                        future: profileFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done) {
                                            if (postList.length == 0)
                                              return Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 30),
                                                  child: ProjectContainer(
                                                    child: Text(
                                                      "There is nothing to show here. \nShare some of your favorite books!",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            else {
                                              return RefreshIndicator(
                                                key: _globalKey,
                                                onRefresh: () {
                                                  return Future.delayed(
                                                      Duration(milliseconds: 50))
                                                      .then((value) =>
                                                  {
                                                    setState(() {
                                                      profileFuture = getAllPosts(currentUser.uid);
                                                    })
                                                  });
                                                },
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height * 0.65,
                                                  child: ListView.builder(
                                                    controller: _scrollController,
                                                    physics: BouncingScrollPhysics(),
                                                    itemCount: postList.length,
                                                    itemBuilder: (BuildContext context,
                                                        int index) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                            left: 5,
                                                            right: 5,
                                                            top: 10),
                                                        child: Container(
                                                          margin: EdgeInsets.only(
                                                              bottom: 5),
                                                          child: boolList[index] ? SmallPostReview(post: postList[index], canBeDeleted: false,)
                                                              : SmallPostQuote(post: postList[index], canBeDeleted: false,),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                          else {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 30.0),
                                              child: Center(child: CircularProgressIndicator()),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ), //My Posts Tab
                              Container(  //MY Library Tab
                                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                                child: GridView.builder(
                                  itemCount: currentUser.library.keys.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 4 / 6,
                                  ),
                                  itemBuilder: (context, index) {
                                    return FutureBuilder(
                                      future: getBookData(currentUser.library.keys.elementAt(index), index),
                                      builder: (context, snapshot) {
                                        return Card(
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => BookPage(book: libraryBooks[index],))
                                              );
                                            },
                                            child: Container(
                                              child: snapshot.connectionState != ConnectionState.done ?
                                              Center(child: CircularProgressIndicator())
                                                  : Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  image: DecorationImage(
                                                    image: CachedNetworkImageProvider(libraryBooks[index].imageUrlL),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), topRight: Radius.circular(30)),
                                                        color: Colors.amber,
                                                        gradient: LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: [Colors.white, Colors.grey[500]],
                                                        ),
                                                      ),
                                                      child: currentUser.library[libraryBooks[index].isbn] == "Finished" ? Icon(
                                                        Icons.book,
                                                        size: 25,
                                                      ) : currentUser.library[libraryBooks[index].isbn] == "Reading" ? Icon(
                                                        Icons.chrome_reader_mode,
                                                        size: 25,
                                                      ) : currentUser.library[libraryBooks[index].isbn] == "Unfinished" ? Icon(
                                                        Icons.close_rounded,
                                                        size: 25,
                                                      ) : Icon(
                                                        Icons.access_time,
                                                        size: 25,
                                                      ),
                                                      padding: EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 20),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ), //MY Library Tab
                            ],
                          ),
                        ),
                        initialIndex: 0,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.253,
                  top: MediaQuery.of(context).size.width * 0.05,
                  child: IconButton(
                    iconSize: 45,
                    icon: Icon(status ? Icons.add_circle_outline : Icons.remove_circle_outline, color: Colors.grey[500],),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () async {
                      await BookDatabase().followFunction(widget.user.uid, !status);
                      setState(() {
                        if (status)
                          currentUser.followers[currentBookworm.uid] = true;
                        else
                          currentUser.followers.remove(currentBookworm.uid);
                        status = !status;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  editModalBottomSheet()  {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          )),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: ListView(
                      padding: EdgeInsets.all(10.0),
                      children: <Widget>[
                        ProjectContainer(
                          child: Column(
                            children: [
                              Text(
                                "Change Picture",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5, left: 3),
                                child: Container(
                                  height: 80,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(80),
                                          color: Colors.blueGrey,
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage:
                                          AssetImage(avatars[currentIndex]),
                                          radius: 25.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: <Widget>[
                                            getAvatars(0, setState),
                                            getAvatars(1, setState),
                                            getAvatars(2, setState),
                                            getAvatars(3, setState),
                                            getAvatars(4, setState),
                                            getAvatars(5, setState),
                                            getAvatars(6, setState),
                                            getAvatars(7, setState),
                                            getAvatars(8, setState),
                                            getAvatars(9, setState),
                                            getAvatars(10, setState),
                                            getAvatars(11, setState),
                                            getAvatars(12, setState),
                                            getAvatars(13, setState),
                                            getAvatars(14, setState),
                                            getAvatars(15, setState),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 30, width: 30),
                              TextFormField(
                                decoration: InputDecoration(labelText: "Name"),
                                //  validator: validateFirstName,
                                controller: _nameController,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30, width: 30),
                        SizedBox(height: 20, width: 30),
                        RaisedButton(
                          onPressed: () {
                            if (_nameController.text != "") {
                              Provider.of<CurrentUser>(context, listen: false)
                                  .saveInfo(currentIndex, _nameController.text);
                              Navigator.maybePop(context);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 100),
                            child: Text("SAVE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    ).then((value) {
      setState(() {
        currentIndex = Provider.of<CurrentUser>(context, listen: false)
            .getCurrentUser
            .photoIndex;
        currentUser =
            Provider.of<CurrentUser>(context, listen: false).getCurrentUser;
      });
    });
  }

  getAvatars(int index, StateSetter setState) {
    return MaterialButton(
      shape: CircleBorder(),
      padding: EdgeInsets.only(left: 0.0, right: 10.0, top: 0.0, bottom: 0.0),
      minWidth: 0,
      child: CircleAvatar(
        backgroundImage: AssetImage(avatars[index]),
        radius: 40.0,
      ),
      onPressed: () {
        setState(() {
          currentIndex = index;
        });
      },
    );
  }

  getBookData(String uid, int index) async {
    if (libraryBooks.length <= index) {
      Book temp = await BookDatabase().getBookInfo(uid);
      libraryBooks.add(temp);
    }
  }
}
