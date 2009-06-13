{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclDebugSerialization.pas.                                                  }
{                                                                                                  }
{ The Initial Developer of the Original Code is Uwe Schuster.                                      }
{ Portions created by Uwe Schuster are Copyright (C) 2009 Uwe Schuster. All rights reserved.       }
{                                                                                                  }
{ Contributor(s):                                                                                  }
{   Uwe Schuster (uschuster)                                                                       }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date::                                                                         $ }
{ Revision:      $Rev::                                                                          $ }
{ Author:        $Author::                                                                       $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclDebugSerialization;

{$I jcl.inc}

interface

uses
  SysUtils, Classes, Contnrs,
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  JclDebug;

type
  TJclCustomSimpleSerializer = class(TObject)
  protected
    FItems: TObjectList;
    FName: string;
    FValues: TStringList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJclCustomSimpleSerializer;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    function AddChild(ASender: TObject; const AName: string): TJclCustomSimpleSerializer;
    procedure Clear;
    function ReadString(ASender: TObject; const AName: string): string;
    procedure WriteString(ASender: TObject; const AName: string; const AValue: string);
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TJclCustomSimpleSerializer read GetItems; default;
    property Name: string read FName;
    property Values: TStringList read FValues;
  end;

  TJclSerializableLocationInfo = class(TJclLocationInfoEx)
  public
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
  end;

  TJclSerializableLocationInfoList = class(TJclCustomLocationInfoList)
  private
    function GetItems(AIndex: Integer): TJclSerializableLocationInfo;
  public
    constructor Create; override;
    function Add(Addr: Pointer): TJclSerializableLocationInfo;
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
    property Items[AIndex: Integer]: TJclSerializableLocationInfo read GetItems; default;
  end;

  TJclSerializableThreadInfo = class(TJclCustomThreadInfo)
  private
    function GetStack(const AIndex: Integer): TJclSerializableLocationInfoList;
  protected
    function GetStackClass: TJclCustomLocationInfoListClass; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
    property CreationStack: TJclSerializableLocationInfoList index 1 read GetStack;
    property Stack: TJclSerializableLocationInfoList index 2 read GetStack;
  end;

  TJclSerializableThreadInfoList = class(TPersistent)
  private
    FItems: TObjectList;
    function GetItems(AIndex: Integer): TJclSerializableThreadInfo;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TJclSerializableThreadInfo;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TJclSerializableThreadInfo read GetItems; default;
  end;

  TException = class(TPersistent)
  private
    FExceptionClassName: string;
    FExceptionMessage: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    procedure Clear;
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
    property ExceptionClassName: string read FExceptionClassName write FExceptionClassName;
    property ExceptionMessage: string read FExceptionMessage write FExceptionMessage;
  end;

  TModule = class(TPersistent)
  private
    FStartStr: string;
    FEndStr: string;
    FSystemModuleStr: string;
    FModuleName: string;
    FBinFileVersion: string;
    FFileVersion: string;
    FFileDescription: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
    property StartStr: string read FStartStr write FStartStr;
    property EndStr: string read FEndStr write FEndStr;
    property SystemModuleStr: string read FSystemModuleStr write FSystemModuleStr;
    property ModuleName: string read FModuleName write FModuleName;
    property BinFileVersion: string read FBinFileVersion write FBinFileVersion;
    property FileVersion: string read FFileVersion write FFileVersion;
    property FileDescription: string read FFileDescription write FFileDescription;
  end;

  TModuleList = class(TPersistent)
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TModule;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TModule;
    procedure Clear;
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TModule read GetItems; default;
  end;

  TExceptionInfo = class(TObject)
  private
    FException: TException;
    FThreadInfoList: TJclSerializableThreadInfoList;
    FModules: TModuleList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Deserialize(ASerializer: TJclCustomSimpleSerializer);
    procedure Serialize(ASerializer: TJclCustomSimpleSerializer);
    property ThreadInfoList: TJclSerializableThreadInfoList read FThreadInfoList;
    property Exception: TException read FException;
    property Modules: TModuleList read FModules;
  end;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL$';
    Revision: '$Revision$';
    Date: '$Date$';
    LogPath: ''
    );
{$ENDIF UNITVERSIONING}

implementation

//=== { TJclCustomSimpleSerializer } =========================================

constructor TJclCustomSimpleSerializer.Create(const AName: string);
begin
  inherited Create;
  FItems := TObjectList.Create;
  FName := AName;
  FValues := TStringList.Create;
end;

destructor TJclCustomSimpleSerializer.Destroy;
begin
  FValues.Free;
  FItems.Free;
  inherited Destroy;
end;

function TJclCustomSimpleSerializer.AddChild(ASender: TObject; const AName: string): TJclCustomSimpleSerializer;
begin
  FItems.Add(TJclCustomSimpleSerializer.Create(AName));
  Result := TJclCustomSimpleSerializer(FItems.Last);
end;

procedure TJclCustomSimpleSerializer.Clear;
begin
  FItems.Clear;
  FValues.Clear;
  FName := '';
end;

function TJclCustomSimpleSerializer.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJclCustomSimpleSerializer.GetItems(AIndex: Integer): TJclCustomSimpleSerializer;
begin
  Result := TJclCustomSimpleSerializer(FItems[AIndex]);
end;

function TJclCustomSimpleSerializer.ReadString(ASender: TObject; const AName: string): string;
begin
  Result := FValues.Values[AName];
end;

procedure TJclCustomSimpleSerializer.WriteString(ASender: TObject; const AName: string; const AValue: string);
begin
  FValues.Add(Format('%s=%s', [AName, AValue]));
end;

//=== { TJclSerializableThreadInfoList } =====================================

constructor TJclSerializableThreadInfoList.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor TJclSerializableThreadInfoList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TJclSerializableThreadInfoList.Add: TJclSerializableThreadInfo;
begin
  FItems.Add(TJclSerializableThreadInfo.Create);
  Result := TJclSerializableThreadInfo(FItems.Last);
end;

procedure TJclSerializableThreadInfoList.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TJclThreadInfoList then
  begin
    Clear;
    for I := 0 to TJclThreadInfoList(Source).Count - 1 do
      Add.Assign(TJclThreadInfoList(Source)[I]);
  end
  else
    inherited Assign(Source);
end;

procedure TJclSerializableThreadInfoList.Clear;
begin
  FItems.Clear;
end;

function TJclSerializableThreadInfoList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJclSerializableThreadInfoList.GetItems(AIndex: Integer): TJclSerializableThreadInfo;
begin
  Result := TJclSerializableThreadInfo(FItems[AIndex]);
end;

procedure TJclSerializableThreadInfoList.Deserialize(ASerializer: TJclCustomSimpleSerializer);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASerializer.Count - 1 do
    if ASerializer[I].Name = 'ThreadInfo' then
      Add.Deserialize(ASerializer[I]);
end;

procedure TJclSerializableThreadInfoList.Serialize(ASerializer: TJclCustomSimpleSerializer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Serialize(ASerializer.AddChild(Self, 'ThreadInfo'));
end;

//=== { TJclSerializableLocationInfo } =======================================

procedure TJclSerializableLocationInfo.Deserialize(ASerializer: TJclCustomSimpleSerializer);
var
  S, SOffsetFromProcName, SLineNumberOffsetFromProcedureStart: string;
begin
  Values := [];
  SOffsetFromProcName := ASerializer.ReadString(Self, 'OffsetFromProcName');
  if SOffsetFromProcName <> '' then
    Values := Values + [lievLocationInfo];
  SLineNumberOffsetFromProcedureStart := ASerializer.ReadString(Self, 'LineNumberOffsetFromProcedureStart');
  if SLineNumberOffsetFromProcedureStart <> '' then
    Values := Values + [lievProcedureStartLocationInfo];
  S := ASerializer.ReadString(Self, 'VAddress');
  VAddress := Pointer(StrToIntDef('$' + S, 0));
  ModuleName := ASerializer.ReadString(Self, 'ModuleName');
  S := ASerializer.ReadString(Self, 'Address');
  Address := Pointer(StrToIntDef('$' + S, 0));
  OffsetFromProcName := StrToIntDef('$' + SOffsetFromProcName, 0);
  SourceUnitName := ASerializer.ReadString(Self, 'UnitName');
  ProcedureName := ASerializer.ReadString(Self, 'ProcedureName');
  SourceName := ASerializer.ReadString(Self, 'SourceName');
  S := ASerializer.ReadString(Self, 'LineNumber');
  LineNumber := StrToIntDef(S, -1);
  S := ASerializer.ReadString(Self, 'OffsetFromLineNumber');
  OffsetFromLineNumber := StrToIntDef(S, -1);
  LineNumberOffsetFromProcedureStart := StrToIntDef(SLineNumberOffsetFromProcedureStart, -1);
  UnitVersionRevision := ASerializer.ReadString(Self, 'Revision');
  //todo more unitversion fields
end;

procedure TJclSerializableLocationInfo.Serialize(ASerializer: TJclCustomSimpleSerializer);
var
  S: string;
begin
  ASerializer.WriteString(Self, 'VAddress', Format('%p', [VAddress]));
  ASerializer.WriteString(Self, 'ModuleName', ModuleName);
  ASerializer.WriteString(Self, 'Address', Format('%p', [Address]));
  if lievLocationInfo in Values then
  begin
    ASerializer.WriteString(Self, 'OffsetFromProcName', Format('+ $%x', [OffsetFromProcName]));
    ASerializer.WriteString(Self, 'UnitName', SourceUnitName);
    ASerializer.WriteString(Self, 'ProcedureName', ProcedureName);
    ASerializer.WriteString(Self, 'SourceName', SourceName);
    if LineNumber > 0 then
    begin
      ASerializer.WriteString(Self, 'LineNumber', IntToStr(LineNumber));
      if OffsetFromLineNumber >= 0 then
        S := S + Format('+ $%x', [OffsetFromLineNumber])
      else
        S := S + Format('- $%x', [-OffsetFromLineNumber]);
      ASerializer.WriteString(Self, 'OffsetFromLineNumber', S);
    end;
    if lievProcedureStartLocationInfo in Values then
      ASerializer.WriteString(Self, 'LineNumberOffsetFromProcedureStart', IntToStr(LineNumberOffsetFromProcedureStart));
  end;
  if lievUnitVersionInfo in Values then
    ASerializer.WriteString(Self, 'Revision', UnitVersionRevision);
  //todo more unitversion fields
end;

//=== { TJclSerializableLocationInfoList } ===================================

function TJclSerializableLocationInfoList.Add(Addr: Pointer): TJclSerializableLocationInfo;
begin
  Result := TJclSerializableLocationInfo(InternalAdd(Addr));
end;

constructor TJclSerializableLocationInfoList.Create;
begin
  inherited Create;
  FItemClass := TJclSerializableLocationInfo;
  FOptions := [];
end;

function TJclSerializableLocationInfoList.GetItems(AIndex: Integer): TJclSerializableLocationInfo;
begin
  Result := TJclSerializableLocationInfo(FItems[AIndex]);
end;

procedure TJclSerializableLocationInfoList.Deserialize(ASerializer: TJclCustomSimpleSerializer);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASerializer.Count - 1 do
    if ASerializer[I].Name = 'LocationInfo' then
      Add(nil).Deserialize(ASerializer[I]);
end;

procedure TJclSerializableLocationInfoList.Serialize(ASerializer: TJclCustomSimpleSerializer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Serialize(ASerializer.AddChild(Self, 'LocationInfo'));
end;

//=== { TJclSerializableThreadInfo } =========================================

constructor TJclSerializableThreadInfo.Create;
begin
  inherited Create;
end;

destructor TJclSerializableThreadInfo.Destroy;
begin
  inherited Destroy;
end;

function TJclSerializableThreadInfo.GetStack(const AIndex: Integer): TJclSerializableLocationInfoList;
begin
  case AIndex of
    1: Result := TJclSerializableLocationInfoList(FCreationStack);
    2: Result := TJclSerializableLocationInfoList(FStack);
    else
      Result := nil;
  end;
end;

function TJclSerializableThreadInfo.GetStackClass: TJclCustomLocationInfoListClass;
begin
  Result := TJclSerializableLocationInfoList;
end;

procedure TJclSerializableThreadInfo.Deserialize(ASerializer: TJclCustomSimpleSerializer);
var
  S: string;
  I: Integer;
begin
  Values := [];
  S := ASerializer.ReadString(Self, 'ThreadID');
  ThreadID := StrToIntDef(S, 0);
  if ASerializer.ReadString(Self, 'MainThread') = '1' then
    Values := Values + [tioIsMainThread];
  S := ASerializer.ReadString(Self, 'Name');
  if S <> '' then
  begin
    Name := S;
    Values := Values + [tioName];
  end;
  S := ASerializer.ReadString(Self, 'CreationTime');
  if S <> '' then
  begin
    CreationTime := StrToDateTime(S);{ TODO -oUSc : ISO format }
    Values := Values + [tioCreationTime];
  end;
  S := ASerializer.ReadString(Self, 'ParentThreadID');
  if S <> '' then
  begin
    ParentThreadID := StrToIntDef(S, 0);
    if ParentThreadID <> 0 then
      Values := Values + [tioParentThreadID];
  end;
  for I := 0 to ASerializer.Count - 1 do
    if ASerializer[I].Name = 'Stack' then
    begin
      Stack.Deserialize(ASerializer[I]);
      Values := Values + [tioStack];
    end
    else
    if ASerializer[I].Name = 'CreationStack' then
    begin
      CreationStack.Deserialize(ASerializer[I]);
      Values := Values + [tioCreationStack];
    end;
end;

procedure TJclSerializableThreadInfo.Serialize(ASerializer: TJclCustomSimpleSerializer);
begin
  ASerializer.WriteString(Self, 'ThreadID', IntToStr(ThreadID));
  if tioIsMainThread in Values then
    ASerializer.WriteString(Self, 'MainThread', '1');
  if tioName in Values then
    ASerializer.WriteString(Self, 'Name', Name);
  if tioCreationTime in Values then
    ASerializer.WriteString(Self, 'CreationTime', DateTimeToStr(CreationTime)); { TODO -oUSc : ISO format }
  if tioParentThreadID in Values then
    ASerializer.WriteString(Self, 'ParentThreadID', IntToStr(ParentThreadID));
  if tioStack in Values then
    Stack.Serialize(ASerializer.AddChild(Self, 'Stack'));
  if tioCreationStack in Values then
    CreationStack.Serialize(ASerializer.AddChild(Self, 'CreationStack'));
end;

//=== { TExceptionInfo } =====================================================

constructor TExceptionInfo.Create;
begin
  inherited Create;
  FException := TException.Create;
  FThreadInfoList := TJclSerializableThreadInfoList.Create;
  FModules := TModuleList.Create;
end;

destructor TExceptionInfo.Destroy;
begin
  FModules.Free;
  FException.Free;
  FThreadInfoList.Free;
  inherited Destroy;
end;

procedure TExceptionInfo.Deserialize(ASerializer: TJclCustomSimpleSerializer);
var
  I: Integer;
begin
  FThreadInfoList.Clear;
  FException.Clear;
  FModules.Clear;
  for I := 0 to ASerializer.Count - 1 do
    if ASerializer[I].Name = 'ThreadInfo' then
      FThreadInfoList.Deserialize(ASerializer[I])
    else
    if ASerializer[I].Name = 'Exception' then
      FException.Deserialize(ASerializer[I])
    else
    if ASerializer[I].Name = 'Modules' then
      FModules.Deserialize(ASerializer[I]);
end;

procedure TExceptionInfo.Serialize(ASerializer: TJclCustomSimpleSerializer);
begin
  FThreadInfoList.Serialize(ASerializer.AddChild(Self, 'ThreadInfo'));
  FException.Serialize(ASerializer.AddChild(Self, 'Exception'));
  FModules.Serialize(ASerializer.AddChild(Self, 'Modules'));
end;

//=== { TException } =========================================================

procedure TException.AssignTo(Dest: TPersistent);
begin
  if Dest is TException then
  begin
    TException(Dest).FExceptionClassName := FExceptionClassName;
    TException(Dest).FExceptionMessage := FExceptionMessage;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TException.Clear;
begin
  FExceptionClassName := '';
  FExceptionMessage := '';
end;

procedure TException.Deserialize(ASerializer: TJclCustomSimpleSerializer);
begin
  Clear;
  FExceptionClassName := ASerializer.ReadString(Self, 'ClassName');
  FExceptionMessage := ASerializer.ReadString(Self, 'Message');
end;

procedure TException.Serialize(ASerializer: TJclCustomSimpleSerializer);
begin
  ASerializer.WriteString(Self, 'ClassName', FExceptionClassName);
  ASerializer.WriteString(Self, 'Message', FExceptionMessage);
end;

//=== { TModule } ============================================================

procedure TModule.AssignTo(Dest: TPersistent);
begin
  if Dest is TModule then
  begin
    TModule(Dest).FStartStr := FStartStr;
    TModule(Dest).FEndStr := FEndStr;
    TModule(Dest).FSystemModuleStr := FSystemModuleStr;
    TModule(Dest).FModuleName := FModuleName;
    TModule(Dest).FBinFileVersion := FBinFileVersion;
    TModule(Dest).FFileVersion := FFileVersion;
    TModule(Dest).FFileDescription := FFileDescription;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TModule.Deserialize(ASerializer: TJclCustomSimpleSerializer);
begin
  FStartStr := ASerializer.ReadString(Self, 'StartAddr');
  FEndStr := ASerializer.ReadString(Self, 'EndAddr');
  FSystemModuleStr := ASerializer.ReadString(Self, 'SystemModule');
  FModuleName := ASerializer.ReadString(Self, 'FileName');
  FBinFileVersion := ASerializer.ReadString(Self, 'BinFileVersion');
  FFileVersion := ASerializer.ReadString(Self, 'FileVersion');
  FFileDescription := ASerializer.ReadString(Self, 'FileDescription');
end;

procedure TModule.Serialize(ASerializer: TJclCustomSimpleSerializer);
begin
  ASerializer.WriteString(Self, 'StartAddr', FStartStr);
  ASerializer.WriteString(Self, 'EndAddr', FEndStr);
  ASerializer.WriteString(Self, 'SystemModule', FSystemModuleStr);
  ASerializer.WriteString(Self, 'FileName', FModuleName);
  ASerializer.WriteString(Self, 'BinFileVersion', FBinFileVersion);
  ASerializer.WriteString(Self, 'FileVersion', FFileVersion);
  ASerializer.WriteString(Self, 'FileDescription', FFileDescription);
end;

//=== { TModuleList } ========================================================

constructor TModuleList.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor TModuleList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TModuleList.Add: TModule;
begin
  FItems.Add(TModule.Create);
  Result := TModule(FItems.Last);
end;

procedure TModuleList.AssignTo(Dest: TPersistent);
var
  I: Integer;
begin
  if Dest is TModuleList then
  begin
    TModuleList(Dest).Clear;
    for I := 0 to Count - 1 do
      TModuleList(Dest).Add.Assign(TModule(FItems[I]));
  end
  else
    inherited AssignTo(Dest);
end;

procedure TModuleList.Clear;
begin
  FItems.Clear;
end;

function TModuleList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TModuleList.GetItems(AIndex: Integer): TModule;
begin
  Result := TModule(FItems[AIndex]);
end;

procedure TModuleList.Deserialize(ASerializer: TJclCustomSimpleSerializer);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASerializer.Count - 1 do
    if ASerializer[I].Name = 'Module' then
      Add.Deserialize(ASerializer[I]);
end;

procedure TModuleList.Serialize(ASerializer: TJclCustomSimpleSerializer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Serialize(ASerializer.AddChild(Self, 'Module'));
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.
