unit UntPrincipal;

interface

uses
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Edit,

  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Bluetooth,
  System.Bluetooth.Components;

//UUID para impressoras Bluetooth
const
  UUID = '{00001101-0000-1000-8000-00805F9B34FB}';

type
  TFontSize = (fsNormal, fsMedium, fsLargeCondensed, fsLarge);

  TAlignment = (alLeft, alCenter, alRight);

  TQRCodeSize = (fsSmall, fsBig);

  TQRCodeMargin = (fsOff, fsOn);

  TfrmPrincipal = class(TForm)
    ListBox1: TListBox;
    lsboxImpressora: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    cbxDevices: TComboBox;
    btnImprimir: TButton;
    BT: TBluetooth;
    Layout2: TLayout;
    Label1: TLabel;
    procedure btnImprimirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbxDevicesChange(Sender: TObject);
  private
    { Private declarations }
    procedure ListarDispositivosPareadosNoCombo;
    function  ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
    function  ConectarImpressora(ANomeDevice: String): Boolean;
    function  MakeScaleScreenshot(const Sender: TControl): TBitmap;
    procedure EnviarImpressao(const Sender: TControl);
    procedure SetFontSize(FontSize: TFontSize);
    procedure SetAlignment(Alignment: TAlignment);
  public
    { Public declarations }
    Socket : TBluetoothSocket;
    procedure ClearBuffer;
    procedure PrintQRCode(Text: String; QRCodeAlign: TAlignment = alLeft; QRCodeMargin: TQRCodeMargin = fsOff; QRCodeSize: TQRCodeSize = fsSmall);
    procedure PrintBarCode(Text: String; BarAlign: TAlignment = alLeft);
    procedure LineBreak;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  ssESCPOSPrintBitmap,
  uAguarde;

{$R *.fmx}

{ TfrmPrincipal }

function TfrmPrincipal.MakeScaleScreenshot(const Sender: TControl): TBitmap;
var
  fScreenScale: Single;
begin
  fScreenScale := 1; // Canvas.Scale; //GetScreenScale;
  Result       := TBitmap.Create(Round(Sender.Width * fScreenScale), Round(Sender.Height * fScreenScale));
  Result.Clear(0);
  if Result.Canvas.BeginScene then
  try
    Sender.PaintTo(Result.Canvas, RectF(0, 0, Result.Width, Result.Height));
  finally
    Result.Canvas.EndScene;
  end;
end;

procedure TfrmPrincipal.btnImprimirClick(Sender: TObject);
var
  FontSize : TFontSize;
  Align : TAlignment;
  QRCodeSize : TQRCodeSize;
  QRCodeMargin : TQRCodeMargin;
  qrData : System.TArray<System.Byte>;
  dataLen: integer;
  dataLen1, dataLen2, marginLen1, marginLen2: byte;
begin
  //ESC/POS
  if (Socket <> nil) and (Socket.Connected) then
  begin
  // Begin FontSize

  //Print Size Normal
  ClearBuffer;
  SetFontSize(fsNormal);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  //Print Size Medium
  SetFontSize(fsMedium);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  //Print Size LargeCondensed
  SetFontSize(fsLargeCondensed);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  //Print Size Large
  SetFontSize(fsLarge);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  //End FontSize

  //---------------------------------

  //Begin Alignment

  //Left
  SetFontSize(fsNormal);
  SetAlignment(alLeft);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  //Center
  SetAlignment(alCenter);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  //Right
  SetAlignment(alRight);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  //Todos os alinhamentos funcionam com qualquer FontSize, basta realizar a chamada conforme o que est� abaixo.
  SetFontSize(fsMedium);
  SetAlignment(alCenter);
  Socket.SendData(TEncoding.UTF8.GetBytes('TEST PRINT'));
  LineBreak;

  Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(100) + Chr(1)));

  //End Alignment

  //---------------------------------

  //Begin QRCode

  //QRCodeSize Small
  Sleep(3000);
  ClearBuffer;
  PrintQRCode('http://www.google.com', alLeft, fsOff, fsSmall);
  LineBreak;
  LineBreak;
  LineBreak;


  //QRCodeSize Big
  PrintQRCode('http://www.google.com', alLeft, fsOff, fsBig);
  LineBreak;
  LineBreak;
  LineBreak;

  //QRCodeAlign Left
  Sleep(3000);
  PrintQRCode('http://www.google.com', alLeft, fsOff, fsSmall);
  LineBreak;
  LineBreak;
  LineBreak;

  //QRCodeAlign Center
  PrintQRCode('http://www.google.com', alCenter, fsOff, fsSmall);
  LineBreak;
  LineBreak;
  LineBreak;

  //QRCodeAlign Right
  PrintQRCode('http://www.google.com', alRight, fsOff, fsSmall);
  LineBreak;
  LineBreak;
  LineBreak;

  //Todos os alinhamentos funcionam com qualquer QRCodeSize, basta realizar a chamada conforme o que est� abaixo.
  PrintQRCode('http://www.google.com', alCenter, fsOff, fsBig);
  LineBreak;
  LineBreak;
  LineBreak;

  //QRCodeMargin Off
  Sleep(3000);
  PrintQRCode('http://www.google.com', alLeft, fsOff, fsSmall);
  LineBreak;
  LineBreak;
  LineBreak;

  //QRCodeMargin On
  PrintQRCode('http://www.google.com', alLeft, fsOn, fsSmall);
  LineBreak;
  LineBreak;
  LineBreak;

  //Todas as margens funcionam com qualquer QRCodeSize e QRCodeAlign, basta realizar a chamada conforme o que est� abaixo.
  PrintQRCode('http://www.google.com', alCenter, fsOn, fsBig);
  LineBreak;
  LineBreak;
  LineBreak;
  Sleep(3000);

  //End QRCode

  //---------------------------------

  //Begin BarCode
  //BarCodeAlign Left
  ClearBuffer;
  PrintBarCode('8983847583721', alLeft);

  //BarCodeAlign Center
  ClearBuffer;
  PrintBarCode('8983847583721', alCenter);

  //BarCodeAlign Right
  ClearBuffer;
  PrintBarCode('8983847583721', alRight);

  //End BarCode

  end;
end;

procedure TfrmPrincipal.ClearBuffer;
begin
  Socket.SendData(TEncoding.UTF8.GetBytes(chr(27) + chr(64)));
end;

procedure TfrmPrincipal.LineBreak;
begin
  Socket.SendData(TEncoding.UTF8.GetBytes(Chr(10)));
end;

procedure TfrmPrincipal.PrintBarCode(Text: String; BarAlign: TAlignment = alLeft);
begin
  SetAlignment(BarAlign);
  Socket.SendData(TEncoding.UTF8.GetBytes(chr(29) + chr(107) + chr(2) + Text + chr(0)));
end;

procedure TfrmPrincipal.PrintQRCode(Text: String; QRCodeAlign: TAlignment = alLeft; QRCodeMargin: TQRCodeMargin = fsOff; QRCodeSize: TQRCodeSize = fsSmall);
var
  qrData : System.TArray<System.Byte>;
  dataLen, align, size: integer;
  dataLen1, dataLen2, marginLen1, marginLen2: byte;
begin
  ClearBuffer;

  //setQRData
  qrData := TEncoding.UTF8.GetBytes(Text + ' ');
  dataLen := high(qrData) + 3;
  dataLen1 := dataLen mod 256;
  dataLen2 := trunc(dataLen / 256);

  //setQRCodeALign
  case QRCodeAlign of
    alLeft:     align := 0;
    alCenter:   align := 1;
    alRight:    align := 2;
  end;

  //setQRCodeMargin
  case QRCodeMargin of
    fsOff:
      begin
          marginLen1 := 0 mod 256;
          marginLen2 := trunc(0 / 256);
          Socket.SendData(TEncoding.UTF8.GetBytes(Chr(29) + Chr(76) + Chr(marginLen1) + Chr(marginLen2)));
      end;
    fsOn:
      begin
          marginLen1 := 32 mod 256;
          marginLen2 := trunc(32 / 256);
          Socket.SendData(TEncoding.UTF8.GetBytes(Chr(29) + Chr(76) + Chr(marginLen1) + Chr(marginLen2)));
      end;
  end;

  //setQRCodeSize
  case QRCodeSize of
    fsSmall: size := 8;
    fsBig:  size := 14;
  end;

  //printQRCode
  Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(97) + Chr(align) + Chr(29) + Chr(81) + Chr(6) + Chr(size) + Chr(4) + Chr(dataLen) + Chr(0)) + qrData);
end;

procedure TfrmPrincipal.SetFontSize(FontSize: TFontSize);
begin
  case FontSize of
    fsNormal:         Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(33) + Chr(0)));
    fsMedium:         Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(33) + Chr(20)));
    fsLargeCondensed: Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(33) + Chr(40)));
    fsLarge:          Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(33) + Chr(60)));
  end;
end;

procedure TfrmPrincipal.SetAlignment(Alignment: TAlignment);
begin
  case Alignment of
    alLeft:   Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(97) + Chr(0)));
    alCenter: Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(97) + Chr(1)));
    alRight:  Socket.SendData(TEncoding.UTF8.GetBytes(Chr(27) + Chr(97) + Chr(2)));
  end;
end;

procedure TfrmPrincipal.EnviarImpressao(const Sender: TControl);
var
  LBuffer  : String;
  Bitmap   : TBitmap;
  I        : Integer;
  viDif    : Integer;
  vbNormal : TBytes;
begin
  Bitmap := MakeScaleScreenshot(Sender);

  LBuffer := #27'3'#30#27'@'  ; //Inicializa a impressora
  LBuffer := LBuffer +  _ESCPosPrintBitmap().RenderBitmapObj(Bitmap) + LBuffer ;

  //Converte a String em Bytes para enviar � impressora...
  SetLength(vbNormal, Length(LBuffer));

  viDif := Abs(Low(LBuffer) - Low(vbNormal));
  for I := Low(LBuffer) to High(LBuffer) do
    vbNormal[I - viDif] := Ord(LBuffer[I]);

  //Imprimir
  if (Socket <> nil) and (Socket.Connected) then
  begin
    Socket.SendData(vbNormal);
  end;
end;
procedure TfrmPrincipal.cbxDevicesChange(Sender: TObject);
begin
  TAguarde.Show(Self, 'Conectando-se ao dispositivo...');
  if (cbxDevices.Selected <> nil) and (cbxDevices.Selected.Text <> EmptyStr) then
  begin
    if ConectarImpressora(cbxDevices.Selected.Text)
    then lsboxImpressora.ItemData.Accessory := TListBoxItemData.TAccessory.aCheckmark
    else lsboxImpressora.ItemData.Accessory := TListBoxItemData.TAccessory.aNone;
  end;
  TAguarde.Hide;
end;

function TfrmPrincipal.ConectarImpressora(ANomeDevice: String): Boolean;
var
  lDevice: TBluetoothDevice;
begin
  Result := False;
  lDevice := ObterDevicePeloNome(ANomeDevice);
  if lDevice <> nil then
  begin
    Socket := lDevice.CreateClientSocket(StringToGUID(UUID), False);
    if Socket <> nil then
    begin
      Socket.Connect;
      Result := Socket.Connected
    end;
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  ListarDispositivosPareadosNoCombo;
end;

procedure TfrmPrincipal.ListarDispositivosPareadosNoCombo;
var
  lDevice: TBluetoothDevice;
begin
  cbxDevices.Clear;
  for lDevice in BT.PairedDevices do
    cbxDevices.Items.Add(lDevice.DeviceName);
end;

function TfrmPrincipal.ObterDevicePeloNome(ANomeDevice: String): TBluetoothDevice;
var
  lDevice: TBluetoothDevice;
begin
  Result := nil;
  for lDevice in BT.PairedDevices do
    if lDevice.DeviceName = ANomeDevice then
      Result := lDevice;
end;

end.
