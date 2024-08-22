import 'package:flutter/material.dart';
import 'package:teklif/base/colors.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/components/custom_text.dart';
import 'package:teklif/components/label_container.dart';
import 'package:teklif/form/offer_form.dart';

class KanbanPage extends StatefulWidget {
  @override
  _KanbanPageState createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  List<Offer> pendingOffers = [];
  List<Offer> approvedOffers = [];
  List<Offer> rejectedOffers = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Örnek teklifler ekliyoruz
    pendingOffers.add(Offer(id: 1, title: 'Teklif 1', description: 'Bekleyen teklif 1'));
    pendingOffers.add(Offer(id: 2, title: 'Teklif 2', description: 'Bekleyen teklif 2'));
    approvedOffers.add(Offer(id: 3, title: 'Teklif 3', description: 'Onaylanan teklif 1'));
    rejectedOffers.add(Offer(id: 4, title: 'Teklif 4', description: 'Reddedilen teklif 1'));
  }

  void _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      List<Offer> oldList = _getListByIndex(oldListIndex);
      List<Offer> newList = _getListByIndex(newListIndex);
      final movedItem = oldList.removeAt(oldItemIndex);
      newList.insert(newItemIndex, movedItem);
    });
  }

  List<Offer> _getListByIndex(int index) {
    switch (index) {
      case 0:
        return pendingOffers;
      case 1:
        return approvedOffers;
      case 2:
        return rejectedOffers;
      default:
        return [];
    }
  }

  void _updateOfferStatus(Offer offer, int currentIndex, int newIndex) {
    setState(() {
      List<Offer> currentList = _getListByIndex(currentIndex);
      List<Offer> newList = _getListByIndex(newIndex);
      currentList.remove(offer);
      newList.add(offer);
    });
  }

  Widget _buildHeader(String title, Color color) {
    return Container(
      padding: EdgeInsets.all(Dimension.getHeight10(context)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Icon(Icons.more_vert, color: Colors.white), // Üç nokta
        ],
      ),
    );
  }


  Widget _buildListItem(Offer offer, int listIndex) {
    return Draggable<Offer>(
      data: offer,
      child: _buildOfferCard(offer, listIndex),
      feedback: Material(
        child: _buildOfferCard(offer, listIndex),
        elevation: 6.0,
      ),
      childWhenDragging: Container(),
    );
  }

  Widget _buildOfferCard(Offer offer, int listIndex) {
    return Padding(
      key: ValueKey(offer.id),
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.all(Dimension.getWidth10(context) / 3),
        width: 260, // Sürüklenen widget'a genişlik veriyoruz
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 6,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        offer.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: listIndex != 0 ? TextDecoration.lineThrough : TextDecoration.none,
                          color: listIndex == 1 ? Colors.green : listIndex == 2 ? Colors.red : Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: (){},
                            child: Icon(Icons.remove_red_eye, color: Colors.grey),
                          ),
                          _buildPopupMenu(offer), // 3 nokta menüsü
                        ],
                      ),

                    ],
                  ),
                  SizedBox(height: Dimension.getHeight10(context) / 5),
                  Text(
                    offer.description,
                    style: TextStyle(fontSize: Dimension.getFont18(context)),
                  ),
                  listIndex == 0
                      ? _buildPendingActions(offer)
                      : listIndex == 1
                      ? _buildApprovedActions(offer)
                      : _buildRejectedActions(offer),
         SizedBox(height: Dimension.getHeight10(context)),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Text("05/06/2024", style: TextStyle(color: Colors.grey),))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPopupMenu(Offer offer) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.green),
              SizedBox(width: 8),
              Text('Düzenle'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Sil'),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        if (value == 'edit') {
          // Düzenleme işlemi burada gerçekleştirilecek
        } else if (value == 'delete') {
          // Silme işlemi burada gerçekleştirilecek
        }
      },
    );
  }

  Widget _buildPendingActions(Offer offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButton(
          title: "Onaylandı olarak işaretle",
          color: Colors.green,
          icon: Icons.check,
          onPressed: () {
            _updateOfferStatus(offer, 0, 1);
          },
        ),
        _buildActionButton(
          title: "Reddedildi olarak işaretle",
          color: Colors.red,
          icon: Icons.close,
          onPressed: () {
            _updateOfferStatus(offer, 0, 2);
          },
        ),
      ],
    );
  }

  Widget _buildApprovedActions(Offer offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButton(
          title: "İşlemde olarak işaretle",
          color: Colors.orange,
          icon: Icons.hourglass_empty,
          onPressed: () {
            _updateOfferStatus(offer, 1, 0);
          },
        ),
        _buildActionButton(
          title: "Reddedildi olarak işaretle",
          color: Colors.red,
          icon: Icons.close,
          onPressed: () {
            _updateOfferStatus(offer, 1, 2);
          },
        ),
      ],
    );
  }

  Widget _buildRejectedActions(Offer offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionButton(
          title: "Onaylandı olarak işaretle",
          color: Colors.green,
          icon: Icons.check,
          onPressed: () {
            _updateOfferStatus(offer, 2, 1);
          },
        ),
        _buildActionButton(
          title: "İşlemde olarak işaretle",
          color: Colors.orange,
          icon: Icons.hourglass_empty,
          onPressed: () {
            _updateOfferStatus(offer, 2, 0);
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: Dimension.getHeight10(context)/2),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          padding:  EdgeInsets.all(Dimension.getHeight10(context)/1.4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: Dimension.getFont12(context),
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GradientContainer(
                colors: [
                  //Colors.orange.shade400, Colors.orange.shade200
                  Colors.grey.shade400,
                  Colors.grey.shade300,
                  Colors.grey.shade200,
                  Colors.grey.shade100
                ],
                child: Center(child: CustomText(text: "Teklifler",fontSize:Dimension.getFont20(context))),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  OfferForm(sector: "ürün")
                  ));
                },
                child: Container(
                  margin: EdgeInsets.all(Dimension.getWidth15(context)),
                  height: Dimension.getHeight10(context) * 5,
                  width: Dimension.getWidth10(context) * 13,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.greentree,
                        AppColors.greentwo,
                        AppColors.greenone
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                    BorderRadius.circular(Dimension.getRadius15(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Yeni Teklif",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimension.getFont18(context),fontFamily: "Merriweather"),
                      ),
                      Icon(
                        Icons.add,
                        color: AppColors.white,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildKanbanColumn('Bekleyen Teklifler', pendingOffers, 0, Colors.orange),
                  _buildKanbanColumn('Onaylanan Teklifler', approvedOffers, 1, Colors.green),
                  _buildKanbanColumn('Reddedilen Teklifler', rejectedOffers, 2,Colors.red),
                  SizedBox(width: 20), // Sonraki sütunlar arasında boşluk bırakmak için
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List<Offer> offers, int listIndex, Color color) {
    return DragTarget<Offer>(
      onAccept: (offer) {
        _updateOfferStatus(offer, _getOfferIndex(offer), listIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 6,
                offset: Offset(1, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(title, color),
              Expanded(
                child: ListView(
                  children: offers.map((offer) => _buildListItem(offer, listIndex)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getOfferIndex(Offer offer) {
    if (pendingOffers.contains(offer)) return 0;
    if (approvedOffers.contains(offer)) return 1;
    if (rejectedOffers.contains(offer)) return 2;
    return -1; // Should not happen
  }
}

class Offer {
  final int id;
  final String title;
  final String description;

  Offer({required this.id, required this.title, required this.description});
}
