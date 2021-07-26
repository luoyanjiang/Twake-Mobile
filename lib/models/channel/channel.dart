import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/channel/channel_role.dart';
import 'package:twake/models/channel/channel_visibility.dart';
import 'package:twake/models/message/message_summary.dart';
import 'package:twake/utils/api_data_transformer.dart';
import 'package:twake/utils/json.dart' as jsn;

export 'channel_visibility.dart';
export 'package:twake/models/message/message_summary.dart';

part 'channel.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Channel extends BaseModel {
  static const COMPOSITE_FIELDS = ['members', 'last_message'];

  final String id;

  @JsonKey(defaultValue: '')
  final String name;

  final String? icon;

  final String? description;

  final String companyId;

  final String workspaceId;

  final List<String> members;

  final ChannelVisibility visibility;

  final int lastActivity;

  final MessageSummary? lastMessage;

  @JsonKey(defaultValue: 0)
  final int userLastAccess;

  String? draft;

  final ChannelRole role;

  bool get hasUnread => userLastAccess < lastActivity;

  int get hash {
    final int hash =
        name.hashCode + icon.hashCode + lastActivity + members.length;
    return hash;
  }

  int get membersCount => members.length;

  bool get isDirect => workspaceId == 'direct';

  bool get isPrivate => visibility == ChannelVisibility.private;

  Channel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.companyId,
    required this.workspaceId,
    this.lastMessage,
    required this.members,
    required this.visibility,
    required this.lastActivity,
    required this.role,
    this.userLastAccess: 0,
    this.draft,
  });

  factory Channel.fromJson({
    required Map<String, dynamic> json,
    bool jsonify: true,
    bool transform: false,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back
    if (transform) {
      json = ApiDataTransformer.channel(json: json);
    }
    if (jsonify) {
      json = jsn.jsonify(json: json, keys: COMPOSITE_FIELDS);
    }
    return _$ChannelFromJson(json);
  }

  Channel copyWith({
    String? name,
    String? icon,
    String? description,
    ChannelVisibility? visibility,
    int? lastActivity,
    MessageSummary? lastMessage,
    int? userLastAccess,
  }) {
    final copy = Channel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      companyId: companyId,
      workspaceId: workspaceId,
      members: members,
      visibility: visibility ?? this.visibility,
      lastActivity: lastActivity ?? this.lastActivity,
      lastMessage: lastMessage ?? this.lastMessage,
      role: this.role,
      userLastAccess: userLastAccess ?? this.userLastAccess,
      draft: draft,
    );

    return copy;
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$ChannelToJson(this);
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields
    if (stringify) {
      json = jsn.stringify(json: json, keys: COMPOSITE_FIELDS);
    }
    return json;
  }
}
