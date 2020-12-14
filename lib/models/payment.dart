// To parse this JSON data, do
//
//     final payment = paymentFromJson(jsonString);

import 'dart:convert';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  Payment({
    this.id,
    this.title,
    this.description,
    this.order,
    this.enabled,
    this.methodTitle,
    this.methodDescription,
    this.methodSupports,
    this.settings,
    this.links,
  });

  String id;
  String title;
  dynamic description;
  String order;
  bool enabled;
  String methodTitle;
  String methodDescription;
  List<String> methodSupports;
  Settings settings;
  Links links;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        order: json["order"],
        enabled: json["enabled"],
        methodTitle: json["method_title"],
        methodDescription: json["method_description"],
        methodSupports:
            List<String>.from(json["method_supports"].map((x) => x)),
        settings: Settings.fromJson(json["settings"]),
        links: Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "order": order,
        "enabled": enabled,
        "method_title": methodTitle,
        "method_description": methodDescription,
        "method_supports": List<dynamic>.from(methodSupports.map((x) => x)),
        "settings": settings.toJson(),
        "_links": links.toJson(),
      };
}

class Links {
  Links({
    this.self,
    this.collection,
  });

  List<Collection> self;
  List<Collection> collection;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: List<Collection>.from(
            json["self"].map((x) => Collection.fromJson(x))),
        collection: List<Collection>.from(
            json["collection"].map((x) => Collection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": List<dynamic>.from(self.map((x) => x.toJson())),
        "collection": List<dynamic>.from(collection.map((x) => x.toJson())),
      };
}

class Collection {
  Collection({
    this.href,
  });

  String href;

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
      };
}

class Settings {
  Settings({
    this.title,
    this.keyId,
    this.keySecret,
    this.paymentAction,
    this.orderSuccessMessage,
    this.enableWebhook,
    this.webhookSecret,
  });

  EnableWebhook title;
  EnableWebhook keyId;
  EnableWebhook keySecret;
  EnableWebhook paymentAction;
  EnableWebhook orderSuccessMessage;
  EnableWebhook enableWebhook;
  EnableWebhook webhookSecret;

// TODO: Check webhooks
  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
      // title: EnableWebhook.fromJson(json["title"]),
      // keyId: EnableWebhook.fromJson(json["key_id"]),
      // keySecret: EnableWebhook.fromJson(json["key_secret"]),
      // paymentAction: EnableWebhook.fromJson(json["payment_action"]),
      // orderSuccessMessage:
      //     EnableWebhook.fromJson(json["order_success_message"]),
      // enableWebhook: EnableWebhook.fromJson(json["enable_webhook"]),
      // webhookSecret: EnableWebhook.fromJson(json["webhook_secret"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title.toJson(),
        "key_id": keyId.toJson(),
        "key_secret": keySecret.toJson(),
        "payment_action": paymentAction.toJson(),
        "order_success_message": orderSuccessMessage.toJson(),
        "enable_webhook": enableWebhook.toJson(),
        "webhook_secret": webhookSecret.toJson(),
      };
}

class EnableWebhook {
  EnableWebhook({
    this.id,
    this.label,
    this.description,
    this.type,
    this.value,
    this.enableWebhookDefault,
    this.tip,
    this.placeholder,
    this.options,
  });

  String id;
  String label;
  String description;
  String type;
  String value;
  String enableWebhookDefault;
  String tip;
  String placeholder;
  Optionss options;

  factory EnableWebhook.fromJson(Map<String, dynamic> json) => EnableWebhook(
        id: json["id"],
        label: json["label"],
        description: json["description"],
        type: json["type"],
        value: json["value"],
        enableWebhookDefault: json["default"],
        tip: json["tip"],
        placeholder: json["placeholder"],
        options:
            json["options"] == null ? null : Optionss.fromJson(json["options"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "description": description,
        "type": type,
        "value": value,
        "default": enableWebhookDefault,
        "tip": tip,
        "placeholder": placeholder,
        "options": options == null ? null : options.toJson(),
      };
}

class Optionss {
  Optionss({
    this.authorize,
    this.capture,
  });

  String authorize;
  String capture;

  factory Optionss.fromJson(Map<String, dynamic> json) => Optionss(
        authorize: json["authorize"],
        capture: json["capture"],
      );

  Map<String, dynamic> toJson() => {
        "authorize": authorize,
        "capture": capture,
      };
}
