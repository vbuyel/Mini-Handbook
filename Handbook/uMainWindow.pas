unit uMainWindow;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.DBCtrls,
  {Added ->} Procedures, SharedData;

type
  TfMain = class(TForm)
    PLeftSide: TPanel;
    MShowTerms: TMemo;
    PUpSide: TPanel;
    MStructure: TMemo;
    BModifyTerm: TButton;
    BSortTerms: TButton;
    BSearchTerm: TButton;
    LTitle: TLabel;
    BExit: TButton;
    PForButtons: TPanel;
    BBack: TButton;
    BInProgramAdd: TButton;
    BInProgramSort: TButton;
    BInProgramSearch: TButton;
    ESortReadOnly: TEdit;
    ESort: TEdit;
    ETerm: TEdit;
    ETermPage: TEdit;
    EUnderTerm: TEdit;
    EUnderTermPage: TEdit;
    EUnderUnderTerm: TEdit;
    EUnderUnderTermPage: TEdit;
    ESearchTerm: TEdit;
    ESearchUnderTerm: TEdit;
    BAddTerm: TButton;
    BChangeTerm: TButton;
    BDeleteTerm: TButton;
    MTermChange: TMemo;
    BInProgramChange: TButton;
    MTermDelete: TMemo;
    BInProgramTermDelete: TButton;
    BClickRightSearch: TButton;
    BClickLeftSearch: TButton;
    BInProgramChangeMain: TButton;
    CBToDelete: TComboBox;
    BUnderUnderTermSearchRight: TButton;
    BUnderUnderTermSearchLeft: TButton;
    BUnderTermSearchRight: TButton;
    BUnderTermSearchLeft: TButton;
    BShowAll: TButton;
    procedure BackInMainMenu(Sender: TObject);
    procedure ExitFromApp(Sender: TObject);
    procedure BModifyTermClick(Sender: TObject);
    procedure BSortTermsClick(Sender: TObject);
    procedure BSearchTermClick(Sender: TObject);
    procedure ESortOnEnter(Sender: TObject);
    procedure ESortOnExit(Sender: TObject);
    procedure ETermOnEnter(Sender: TObject);
    procedure ETermPageOnEnter(Sender: TObject);
    procedure EUnderTermOnEnter(Sender: TObject);
    procedure EUnderTermPageOnEnter(Sender: TObject);
    procedure EUnderUnderTermOnEnter(Sender: TObject);
    procedure EUnderUnderTermPageOnEnter(Sender: TObject);
    procedure ETermOnExit(Sender: TObject);
    procedure ETermPageOnExit(Sender: TObject);
    procedure EUnderTermOnExit(Sender: TObject);
    procedure EUnderTermPageOnExit(Sender: TObject);
    procedure EUnderUnderTermOnExit(Sender: TObject);
    procedure EUnderUnderTermPageOnExit(Sender: TObject);
    procedure ESearchTermOnEnter(Sender: TObject);
    procedure ESearchUnderTermOnEnter(Sender: TObject);
    procedure ESearchTermOnExit(Sender: TObject);
    procedure ESearchUnderTermOnExit(Sender: TObject);
    procedure BAddTermClick(Sender: TObject);
    procedure BDeleteTermClick(Sender: TObject);
    procedure BChangeTermsClick(Sender: TObject);
    procedure MTermChangeOnEnter(Sender: TObject);
    procedure MTermChangeOnExit(Sender: TObject);
    procedure MTermDeleteOnEnter(Sender: TObject);
    procedure MTermDeleteOnExit(Sender: TObject);
    procedure BInProgramChangeTerm(Sender: TObject);
    procedure BInProgramAddClick(Sender: TObject);
    procedure BClickRightSearchClick(Sender: TObject);
    procedure BClickLeftSearchClick(Sender: TObject);
    procedure DeleteTermElements(Sender: TObject);
    procedure BInProgramFind(Sender: TObject);
    procedure BSearchUnderTermLeft(Sender: TObject);
    procedure BSearchUnderTermRight(Sender: TObject);
    procedure BSearchUnderUnderTermLeft(Sender: TObject);
    procedure BSearchUnderUnderTermRight(Sender: TObject);
    procedure BInProgramSearchClick(Sender: TObject);
    procedure BInProgramSortClick(Sender: TObject);
    procedure BShowAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMain: TfMain;
  Movement: string;

implementation

{$R *.dfm}

var
  i: 0..TableSize;
  TermTemp: PTerm;

procedure HideMainButtons(BAdd, BSort, BSearch, BExit, BBackInMainMenu: TButton);
begin
  BAdd.Visible := False;
  BSort.Visible := False;
  BSearch.Visible := False;
  BExit.Visible := False;

  BBackInMainMenu.Top := BExit.Top;
  BBackInMainMenu.Left := BExit.Left;
  BBackInMainMenu.Visible := True;
end;

procedure TfMain.BackInMainMenu(Sender: TObject);
var
  i: integer;
  Found: boolean;
begin
  PLeftSide.Width := 361;

  BModifyTerm.Visible := True;
  BSortTerms.Visible := True;
  BSearchTerm.Visible := True;
  BExit.Visible := True;

  BBack.Visible := False;
  BInProgramAdd.Visible := False;
  BInProgramSort.Visible := False;
  BInProgramSearch.Visible := False;

  ESortReadOnly.Visible := False;
  ESort.Visible := False;

  ETerm.Visible := False;
  EUnderTerm.Visible := False;
  EUnderUnderTerm.Visible := False;
  ETermPage.Visible := False;
  EUnderTermPage.Visible := False;
  EUnderUnderTermPage.Visible := False;

  ESearchTerm.Visible := False;
  ESearchUnderTerm.Visible := False;
  BClickLeftSearch.Visible := False;
  BClickRightSearch.Visible := False;

  BAddTerm.Visible := False;
  BChangeTerm.Visible := False;
  BDeleteTerm.Visible := False;

  MTermChange.Visible := False;
  BInProgramChange.Visible := False;
  MTermDelete.Visible := False;
  BInProgramTermDelete.Visible := False;

  BInProgramChangeMain.Visible := False;
  CBToDelete.Visible := False;

  BUnderTermSearchLeft.Visible := False;
  BUnderTermSearchRight.Visible := False;
  BUnderUnderTermSearchLeft.Visible := False;
  BUnderUnderTermSearchRight.Visible := False;

  BShowAll.Visible := True;

  for i := 0 to TableSize-1 do
     if TermTable[i] <> nil then
       Found := True;

  BShowAll.Enabled := False;
  if Found then BShowAll.Enabled := True;

  InStartPosition;

end;

procedure TfMain.BModifyTermClick(Sender: TObject);
begin
  HideMainButtons(BModifyTerm, BSortTerms, BSearchTerm, BExit, BBack);
  BShowAll.Visible := False;

  BAddTerm.Top := BModifyTerm.Top;
  BAddTerm.Left := BModifyTerm.Left;

  BChangeTerm.Top := BSortTerms.Top;
  BChangeTerm.Left := BSortTerms.Left;

  BDeleteTerm.Top := BSearchTerm.Top;
  BDeleteTerm.Left := BSearchTerm.Left;

  BAddTerm.Visible := True;
  BChangeTerm.Visible := True;
  BDeleteTerm.Visible := True;
end;

procedure TfMain.BAddTermClick(Sender: TObject);
begin
  HideMainButtons(BAddTerm, BChangeTerm, BDeleteTerm, BExit, BBack);

  BInProgramAdd.Top := BSearchTerm.Top;
  BinProgramAdd.Left := BSearchTerm.Left;
  BInProgramAdd.Visible := True;

  ETerm.Top := BInProgramAdd.Top - 117;
  EUnderTerm.Top := BInProgramAdd.Top - 85;
  EUnderUnderTerm.Top := BInProgramAdd.Top - 53;
  ETerm.Left := BInProgramAdd.Left;
  EUnderTerm.Left := BInProgramAdd.Left;
  EUnderUnderTerm.Left := BInProgramAdd.Left;

  ETermPage.Top := BInProgramAdd.Top - 117;
  EUnderTermPage.Top := BInProgramAdd.Top - 85;
  EUnderUnderTermPage.Top := BInProgramAdd.Top - 53;
  ETermPage.Left := BInProgramAdd.Left + 153;
  EUnderTermPage.Left := BInProgramAdd.Left + 153;
  EUnderUnderTermPage.Left := BInProgramAdd.Left + 153;

  ETerm.Visible := True;
  EUnderTerm.Visible := True;
  EUnderUnderTerm.Visible := True;
  ETermPage.Visible := True;
  EUnderTermPage.Visible := True;
  EUnderUnderTermPage.Visible := True;
end;

procedure TfMain.BSearchTermClick(Sender: TObject);
begin
  HideMainButtons(BModifyTerm, BSortTerms, BSearchTerm, BExit, BBack);
  BShowAll.Visible := False;

  BInProgramSearch.Top := BSearchTerm.Top;
  BinProgramSearch.Left := BSearchTerm.Left;
  BInProgramSearch.Visible := True;

  ESearchTerm.Top := BModifyTerm.Top + 40;
  ESearchUnderTerm.Top := BModifyTerm.Top + 40;
  ESearchTerm.Left := BModifyTerm.Left;
  ESearchUnderTerm.Left := BModifyTerm.Left;

  // Код для показа: что будет отображаться...
//    ESearchUnderTerm.Visible := True;
    // или
  ESearchTerm.Visible := True;

  BClickLeftSearch.Top := BInProgramSearch.Top - 42;
  BClickRightSearch.Top := BInProgramSearch.Top - 42;
  BClickLeftSearch.Left := 232;
  BClickRightSearch.Left := 288;
  BClickLeftSearch.Visible := True;
  BClickRightSearch.Visible := True;
end;

procedure TfMain.BSortTermsClick(Sender: TObject);
begin
  HideMainButtons(BModifyTerm, BSortTerms, BSearchTerm, BExit, BBack);
  BShowAll.Visible := False;

  BInProgramSort.Top := BSearchTerm.Top;
  BinProgramSort.Left := BSearchTerm.Left;
  BInProgramSort.Visible := True;

  ESortReadOnly.Top := BInProgramSort.Top - 60;
  ESortReadOnly.Left := BinProgramSort.Left;
  ESort.Top := BInProgramSort.Top - 60;
  ESort.Left := BinProgramSort.Left + 91;
  ESortReadOnly.Visible := True;
  ESort.Visible := True;
end;

procedure TfMain.BChangeTermsClick(Sender: TObject);
begin
  HideMainButtons(BAddTerm, BChangeTerm, BDeleteTerm, BExit, BBack);
// ---
  BInProgramChange.Top := BSearchTerm.Top;
  BinProgramChange.Left := BSearchTerm.Left;
  BInProgramChange.Visible := True;
// ---
  MTermChange.Top := BModifyTerm.Top + 30;
  MTermChange.Left := BModifyTerm.Left;
  MTermChange.Visible := True;

//  CBChooseToChange.Top := BInProgramChange.Top - 42;
//  CBChooseToChange.Left := 182;
//  CBChooseToChange.Visible := True;

  //BClickLeftChange.Top := BInProgramChange.Top - 42;
  //BClickRightChange.Top := BInProgramChange.Top - 42;
  //BClickLeftChange.Left := 232;
  //BClickRightChange.Left := 288;
  //BClickLeftChange.Visible := True;
  //BClickRightChange.Visible := True;
end;

procedure TfMain.BClickLeftSearchClick(Sender: TObject);
begin
  ESearchUnderTerm.Visible := False;
  ESearchTerm.Visible := True;

  BClickLeftSearch.Enabled := False;
  BClickRightSearch.Enabled := True;
end;

procedure TfMain.BClickRightSearchClick(Sender: TObject);
begin
  ESearchUnderTerm.Visible := True;
  ESearchTerm.Visible := False;

  BClickRightSearch.Enabled := False;
  BClickLeftSearch.Enabled := True;
end;

// --------------------------------------------------------------------- DELETE
procedure TfMain.DeleteTermElements(Sender: TObject);
var
  i: byte;
  Found: boolean;
begin
  Found := False;

  CBToDelete.ItemIndex;  // 0 - 3

  Delete(CBToDelete.ItemIndex, MTermDelete, ETerm, EUnderTerm, EUnderUnderTerm);

  PrintList(MShowTerms);

  for i := 0 to TableSize-1 do
    if TermTable[i] <> nil then
      Found := True;

  if Found then BShowAll.Enabled := True;
end;                                                                     // ---

procedure TfMain.BDeleteTermClick(Sender: TObject);
begin
  HideMainButtons(BAddTerm, BChangeTerm, BDeleteTerm, BExit, BBack);
// ---
  BInProgramTermDelete.Top := BSearchTerm.Top;
  BInProgramTermDelete.Left := BSearchTerm.Left;
  BInProgramTermDelete.Visible := True;
// ---

  CBToDelete.Top := BModifyTerm.Top;
  CBToDelete.Left := 182;
  CBToDelete.Visible := True;

  MTermDelete.Top := BModifyTerm.Top + 30;
  MTermDelete.Left := BModifyTerm.Left;
  MTermDelete.Visible := True;
end;

procedure TfMain.BInProgramAddClick(Sender: TObject);
var
  Index: integer;
  i, TermInd: byte;
  UnderTermTemp: PUnderTerm;
  UnderUnderTermTemp: PUnderUnderTerm;
  PageSwapSST, PageTempSST, PageSwapST, PageTempST, PageSwapT, PageTempT: PPages;
  FoundTerm, FoundUnderTerm, FoundUnderUnderTerm: boolean;
begin
  AllErrors := 0;
  Error := 0;

  CheckingString := ETermPage.Text;
  val(CheckingString, CheckedInt, Error);
  AllErrors := AllErrors + Error;

  CheckingString := EUnderTermPage.Text;
  if CheckingString = 'Номер страницы' then CheckingString := 'NAN';
  val(CheckingString, CheckedInt, Error);
  AllErrors := AllErrors + Error;

  CheckingString := EUnderUnderTermPage.Text;
  if CheckingString = 'Номер страницы' then CheckingString := 'NAN';
  val(CheckingString, CheckedInt, Error);
  AllErrors := AllErrors + Error;


  if (ETerm.Text <> 'Термин') and (ETermPage.Text <> 'Номер страницы') and (AllErrors = 0) then
  begin
    TermTemp := nil;
    FoundTerm := False;
    FoundUnderTerm := False;
    FoundUnderUnderTerm := False;

    New(TermTemp);
    New(TermTemp.TermCurr);
    New(TermTemp.TermCurr.TermPage);
    New(TermTemp.TermCurr.UnderTerm);
    New(TermTemp.TermCurr.UnderTerm.UnderTermPage);
    New(TermTemp.TermCurr.UnderTerm.UnderUnderTerm);
    New(TermTemp.TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage);
    TermInd := 0;

    Add(ETerm, ETermPage,
        EUnderTerm, EUnderTermPage,
        EUnderUnderTerm, EUnderUnderTermPage);

    // Print on memo
    Movement := 'Add';
    PrintList(MShowTerms);
  end
  else
    Showmessage('Ошибка: необходимо ввести Термин и Страницу, где находится этот термин');

  BShowAll.Enabled := True;
end;


procedure TfMain.BInProgramFind(Sender: TObject);
begin
  PLeftSide.Width := 461;

  New(TermTemp);
  New(TermTemp^.TermCurr);
  New(TermTemp.TermCurr^.TermPage);
  New(TermTemp.TermCurr^.UnderTerm);
  New(TermTemp.TermCurr.UnderTerm^.UnderTermPage);
  New(TermTemp.TermCurr.UnderTerm^.UnderUnderTerm);
  New(TermTemp.TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage);

  // Initialization
  TermTemp.TermCurr.TermName := MTermChange.Lines[0];

  i := SearchTerm(TermTemp);

  if i = TableSize then
  begin
    ShowMessage('Такого термина не нашлось :(');
    Exit;
  end;

  TermTemp := TermTable[i];

  BInProgramChange.Visible := False;
  MTermChange.Visible := False;

  ETerm.Top := BInProgramChange.Top - 117;
  EUnderTerm.Top := BInProgramChange.Top - 85;
  EUnderUnderTerm.Top := BInProgramChange.Top - 53;
  ETerm.Left := BInProgramChange.Left;
  EUnderTerm.Left := BInProgramChange.Left;
  EUnderUnderTerm.Left := BInProgramChange.Left;

  ETermPage.Top := BInProgramChange.Top - 117;
  EUnderTermPage.Top := BInProgramChange.Top - 85;
  EUnderUnderTermPage.Top := BInProgramChange.Top - 53;
  ETermPage.Left := BInProgramChange.Left + 153;
  EUnderTermPage.Left := BInProgramChange.Left + 153;
  EUnderUnderTermPage.Left := BInProgramChange.Left + 153;

  ETerm.Visible := True;
  ETermPage.Visible := True;
  EUnderTerm.Visible := True;
  EUnderTermPage.Visible := True;
  EUnderUnderTerm.Visible := True;
  EUnderUnderTermPage.Visible := True;

  BInProgramChangeMain.Top := BInProgramChange.Top;
  BInProgramChangeMain.Left := BInProgramChange.Left;
  BInProgramChangeMain.Visible := True;

  BUnderTermSearchLeft.Left := EUnderTermPage.Left + 170;
  BUnderUnderTermSearchLeft.Left := EUnderUnderTermPage.Left + 170;
  BUnderTermSearchLeft.Top := EUnderTermPage.Top;
  BUnderUnderTermSearchLeft.Top := EUnderUnderTermPage.Top;
  BUnderTermSearchRight.Left := BUnderTermSearchLeft.Left + 55;
  BUnderUnderTermSearchRight.Left := BUnderUnderTermSearchLeft.Left + 55;
  BUnderTermSearchRight.Top := EUnderTermPage.Top;
  BUnderUnderTermSearchRight.Top := EUnderUnderTermPage.Top;

  BUnderTermSearchLeft.Visible := True;
  BUnderTermSearchRight.Visible := True;
  BUnderUnderTermSearchRight.Visible := True;
  BUnderUnderTermSearchLeft.Visible := True;

  if TermTable[i].TermCurr.UnderTerm^.UnderTermPrev = nil then
    BUnderTermSearchLeft.Enabled := False;

  if TermTable[i].TermCurr.UnderTerm^.UnderTermNext = nil then
    BUnderTermSearchRight.Enabled := False;

  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPrev = nil then
    BUnderUnderTermSearchLeft.Enabled := False;

  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermNext = nil then
    BUnderUnderTermSearchRight.Enabled := False;

  // Show terms in Edits
  ETerm.Text := TermTable[i].TermCurr.TermName;
  ETermPage.Text := IntToStr(TermTable[i].TermCurr.TermPage.Page);

  EUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderTermName;
  EUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderTermPage.Page);

  EUnderUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName;
  EUnderUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage.Page);
end;

procedure TfMain.BInProgramSearchClick(Sender: TObject);
var
  Found: boolean;
  i: integer;
begin
  Found := False;
  For i := 0 to TableSize-1 do
    If TermTable[i] <> nil then
      Found := True;

  If Found = False then
  begin
    ShowMessage('Добавьте хотя бы один термин, подтермин и под-подтермин');
    Exit;
  end;

  If (ESearchTerm.Text = 'Поиск термина по подтермину') and (ESearchUnderTerm.Text = 'Поиск подтермина по подподтермину') then
    ShowMessage('Введите в поле для поиска')
  Else
    If BClickLeftSearch.Enabled = False then
    begin
      MShowTerms.Clear;
      MShowTerms.Lines.Add('Найденые термины с подтермином ' + ESearchTerm.Text + ':');
      MShowTerms.Lines.Add('');
      Search(0, ESearchTerm.Text, MShowTerms);
    end
    Else
    begin
      MShowTerms.Clear;
      MShowTerms.Lines.Add('Найденые подтермины с под-подтермином ' + ESearchUnderTerm.Text + ':');
      MShowTerms.Lines.Add('');
      Search(1, ESearchUnderTerm.Text, MShowTerms);
    end;
end;

procedure TfMain.BInProgramSortClick(Sender: TObject);
begin
  if LowerCase(Trim(ESort.Text)) = 'алфавиту' then
  begin
    SortInAlphabet(MShowTerms);
  end
  else if LowerCase(Trim(ESort.Text)) = 'номерам страниц' then
  begin
    SortInPageNums(MShowTerms);
  end
  else
    ShowMessage('Убедитесь, что Вы ввели "Алфавиту" или "Номкрам страниц"');
end;

procedure TFMain.BSearchUnderTermRight(Sender: TObject);
begin
  TermTable[i].TermCurr^.UnderTerm := TermTable[i].TermCurr.UnderTerm^.UnderTermNext;

  // Show terms in Edits
  if TermTable[i]^.TermCurr <> nil then
  begin
    ETerm.Text := TermTable[i].TermCurr.TermName;
    ETermPage.Text := IntToStr(TermTable[i].TermCurr.TermPage.Page);

    if TermTable[i].TermCurr^.UnderTerm <> nil then
    begin
      EUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderTermName;
      EUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderTermPage.Page);

      if TermTable[i].TermCurr.UnderTerm^.UnderUnderTerm <> nil then
      begin
        EUnderUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName;
        EUnderUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage.Page);
      end;
    end;
  end;

  if TermTable[i].TermCurr.UnderTerm^.UnderTermNext = nil then
    BUnderTermSearchRight.Enabled := False;

  BUnderTermSearchLeft.Enabled := True;
  BUnderUnderTermSearchRight.Enabled := True;
  BUnderUnderTermSearchLeft.Enabled := True;
  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermNext = nil then
    BUnderUnderTermSearchRight.Enabled := False;
  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPrev = nil then
    BUnderUnderTermSearchLeft.Enabled := False;
end;

procedure TFMain.BSearchUnderTermLeft(Sender: TObject);
begin
  TermTable[i].TermCurr^.UnderTerm := TermTable[i].TermCurr.UnderTerm^.UnderTermPrev;

  // Show terms in Edits
  ETerm.Text := TermTable[i].TermCurr.TermName;
  ETermPage.Text := IntToStr(TermTable[i].TermCurr.TermPage.Page);

  EUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderTermName;
  EUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderTermPage.Page);

  EUnderUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName;
  EUnderUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage.Page);

  if TermTable[i].TermCurr.UnderTerm^.UnderTermPrev = nil then
    BUnderTermSearchLeft.Enabled := False;

  BUnderTermSearchRight.Enabled := True;
  BUnderUnderTermSearchRight.Enabled := True;
  BUnderUnderTermSearchLeft.Enabled := True;
  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermNext = nil then
    BUnderUnderTermSearchRight.Enabled := False;
  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPrev = nil then
    BUnderUnderTermSearchLeft.Enabled := False;
end;

procedure TFMain.BSearchUnderUnderTermLeft(Sender: TObject);
begin
  TermTable[i].TermCurr.UnderTerm^.UnderUnderTerm := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPrev;

  // Show terms in Edits
  ETerm.Text := TermTable[i].TermCurr.TermName;
  ETermPage.Text := IntToStr(TermTable[i].TermCurr.TermPage.Page);

  EUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderTermName;
  EUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderTermPage.Page);

  EUnderUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName;
  EUnderUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage.Page);

  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPrev = nil then
    BUnderUnderTermSearchLeft.Enabled := False;

  BUnderUnderTermSearchRight.Enabled := True;
end;

procedure TFMain.BSearchUnderUnderTermRight(Sender: TObject);
begin
  TermTable[i].TermCurr.UnderTerm^.UnderUnderTerm := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermNext;

  // Show terms in Edits
  ETerm.Text := TermTable[i].TermCurr.TermName;
  ETermPage.Text := IntToStr(TermTable[i].TermCurr.TermPage.Page);

  EUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderTermName;
  EUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderTermPage.Page);

  EUnderUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName;
  EUnderUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage.Page);

  if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermNext = nil then
    BUnderUnderTermSearchRight.Enabled := False;

  BUnderUnderTermSearchLeft.Enabled := True;
end;

procedure TfMain.BShowAllClick(Sender: TObject);
begin
  PrintList(MShowTerms);
end;

procedure TfMain.BInProgramChangeTerm(Sender: TObject);
var
  k: 0..TableSize;
begin
  // Change parameters
  TermTable[i].TermCurr.TermName := ETerm.Text;
  TermTable[i].TermCurr.TermPage.Page := StrToInt(ETermPage.Text);

  TermTable[i].TermCurr.UnderTerm.UnderTermName := EUnderTerm.Text;
  TermTable[i].TermCurr.UnderTerm.UnderTermPage.Page := StrToInt(EUnderTermPage.Text);

  TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName := EUnderUnderTerm.Text;
  TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage.Page := StrToInt(EUnderUnderTermPage.Text);

  InStartPosition;
  BUnderTermSearchRight.Enabled := True;
  BUnderUnderTermSearchRight.Enabled := True;
  BUnderTermSearchLeft.Enabled := False;
  BUnderUnderTermSearchLeft.Enabled := False;
  PrintList(MShowTerms);

  // Show terms in Edits
  ETerm.Text := TermTable[i].TermCurr.TermName;
  ETermPage.Text := IntToStr(TermTable[i].TermCurr.TermPage.Page);

  EUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderTermName;
  EUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderTermPage.Page);

  EUnderUnderTerm.Text := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName;
  EUnderUnderTermPage.Text := IntToStr(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage.Page);
end;

procedure TfMain.ExitFromApp(Sender: TObject);
begin
  Application.Terminate;
end;

Procedure ENameEnter(EName: TEdit; Text: String);
Begin
  If EName.Text = Text then
  Begin
    EName.Text := '';
    EName.Font.Color := clBlack;
  End;
End;

Procedure ENameExit(EName: TEdit; Text: String);
Begin
  If EName.Text = '' then
  Begin
    EName.Text := Text;
    EName.Font.Color := clGray;
  End;
End;

Procedure MNameEnter(MName: TMemo; Text: String);
Begin
  If MName.Lines[0] = Text then
  Begin
    MName.Text := '';
    MName.Font.Color := clBlack;
  End;
End;

Procedure MNameExit(MName: TMemo; Text: String);
Begin
  If MName.Lines[0] = '' then
  Begin
    MName.Text := Text;
    MName.Font.Color := clGray;
  End;
End;

procedure TfMain.MTermChangeOnEnter(Sender: TObject);
begin
  MNameEnter(MTermChange, 'Введите "термин", который Вы хотите изменить');
end;

procedure TfMain.MTermChangeOnExit(Sender: TObject);
begin
  MNameExit(MTermChange, 'Введите "термин", который Вы хотите изменить');
end;

procedure TfMain.MTermDeleteOnEnter(Sender: TObject);
begin
  MNameEnter(MTermDelete, 'Введите, что Вы хотите удалить');
end;

procedure TfMain.MTermDeleteOnExit(Sender: TObject);
begin
  MNameExit(MTermDelete, 'Введите, что Вы хотите удалить');
end;

procedure TfMain.ESortOnEnter(Sender: TObject);
begin
  ENameEnter(ESort, 'алфавиту/номерам страниц');
end;


// ---

procedure TfMain.ETermOnEnter(Sender: TObject);
begin
  ENameEnter(ETerm, 'Термин');
end;

procedure TfMain.ETermPageOnEnter(Sender: TObject);
begin
  ENameEnter(ETermPage, 'Номер страницы');
end;

// ---

procedure TfMain.EUnderTermOnEnter(Sender: TObject);
begin
  ENameEnter(EUnderTerm, 'Подтермин');
end;

procedure TfMain.EUnderTermPageOnEnter(Sender: TObject);
begin
  ENameEnter(EUnderTermPage, 'Номер страницы');
end;

// ---

procedure TfMain.EUnderUnderTermOnEnter(Sender: TObject);
begin
  ENameEnter(EUnderUnderTerm, 'Подподтермин');
end;

procedure TfMain.EUnderUnderTermPageOnEnter(Sender: TObject);
begin
  ENameEnter(EUnderUnderTermPage, 'Номер страницы');
end;

// ---

// ---

procedure TfMain.ETermOnExit(Sender: TObject);
begin
  ENameExit(ETerm, 'Термин');
end;

procedure TfMain.ETermPageOnExit(Sender: TObject);
begin
  ENameExit(ETermPage, 'Номер страницы');
end;

// ---

procedure TfMain.EUnderTermOnExit(Sender: TObject);
begin
  ENameExit(EUnderTerm, 'Подтермин');
end;

procedure TfMain.EUnderTermPageOnExit(Sender: TObject);
begin
  ENameExit(EUnderTermPage, 'Номер страницы');
end;

// ---

procedure TfMain.EUnderUnderTermOnExit(Sender: TObject);
begin
  ENameExit(EUnderUnderTerm, 'Подподтермин');
end;

procedure TfMain.EUnderUnderTermPageOnExit(Sender: TObject);
begin
  ENameExit(EUnderUnderTermPage, 'Номер страницы');
end;

// ---


// ---

procedure TfMain.ESearchTermOnEnter(Sender: TObject);
begin
  ENameEnter(ESearchTerm, 'Поиск термина по подтермину');
end;

procedure TfMain.ESearchUnderTermOnEnter(Sender: TObject);
begin
  ENameEnter(ESearchUnderTerm, 'Поиск подтермина по подподтермину');
end;

// ---

// ---

procedure TfMain.ESearchTermOnExit(Sender: TObject);
begin
  ENameExit(ESearchTerm, 'Поиск термина по подтермину');
end;

procedure TfMain.ESearchUnderTermOnExit(Sender: TObject);
begin
  ENameExit(ESearchUnderTerm, 'Поиск подтермина по подподтермину');
end;

// ---


procedure TfMain.ESortOnExit(Sender: TObject);
begin
  ENameExit(ESort, 'алфавиту/номерам страниц');
end;

end.
