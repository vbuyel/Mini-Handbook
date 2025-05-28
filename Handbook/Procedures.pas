unit Procedures;

interface

Uses
  SharedData, Vcl.StdCtrls, Graphics;

procedure Delete(DeepPoint: Integer; MemoSelected: TMemo;
                 ETerm, EUnderTerm, EUnderUnderTerm: TEdit);
procedure Add(ETerm, ETermPage,
              EUnderTerm, EUnderTermPage,
              EUnderUnderTerm, EUnderUnderTermPage: TEdit);
procedure PrintList(ShowInMemo: TMemo);
function SearchTerm(Term: PTerm): byte;
procedure InStartPosition;
procedure Search(Access: Integer; FindStr: String; Memo: TMemo);
procedure SortInAlphabet(Memo: TMemo);
procedure SortInPageNums(Memo: TMemo);

implementation

Uses
  SysUtils, uMainWindow;

Type
  ForTArray = array of PTerm;
  ForSTArray = array of PUnderTermCurr;
  ForSSTArray = array of PUnderUnderTermCurr;

Var
  TArray: ForTArray;

// ----------------------------------------------------------- Work with SSTerm
function SSTToArrayAndSort(var ThisUnderTerm: PUnderTerm): PUnderUnderTerm;
var
  i, k, j: integer;
  ThisSSArray: array of PUnderUnderTerm;
begin
  i := 0;
  while True do
  begin
    Inc(i);
    SetLength(ThisSSArray, i);
    ThisSSArray[i-1] := ThisUnderTerm^.UnderUnderTerm;

    if ThisUnderTerm.UnderUnderTerm^.UnderUnderTermNext <> nil then
      ThisUnderTerm^.UnderUnderTerm := ThisUnderTerm.UnderUnderTerm^.UnderUnderTermNext
    else
      break;
  end;

  for k := 0 to i-2 do
    for j := k+1 to i-1 do
      if ThisSSArray[k].UnderUnderTermName > ThisSSArray[j].UnderUnderTermName then
      begin
        var Temp := ThisSSArray[k];
        ThisSSArray[k] := ThisSSArray[j];
        ThisSSArray[j] := Temp;
      end;

  for k := 0 to i-2 do
  begin
    ThisSSArray[k]^.UnderUnderTermNext := ThisSSArray[k+1];
    ThisSSArray[k+1]^.UnderUnderTermPrev := ThisSSArray[k];
  end;
  ThisSSArray[0]^.UnderUnderTermPrev := nil;
  ThisSSArray[i-1]^.UnderUnderTermNext := nil;

  SSTToArrayAndSort := ThisSSArray[0];
end;

// ----------------------------------------------------------- Work with SSTerm
function STToArrayAndSort(var ThisTerm: PTermCurr): PUnderTerm;
var
  i, k, j: integer;
  ThisSArray: array of PUnderTerm;
begin
  i := 0;
  while True do
  begin
    Inc(i);
    SetLength(ThisSArray, i);
    ThisSArray[i-1] := ThisTerm^.UnderTerm;

    ThisSArray[i-1]^.UnderUnderTerm := SSTToArrayAndSort(ThisTerm^.UnderTerm);

    if ThisTerm.UnderTerm^.UnderTermNext <> nil then
      ThisTerm^.UnderTerm := ThisTerm.UnderTerm^.UnderTermNext
    else
      break;
  end;

  for k := 0 to i-2 do
    for j := k+1 to i-1 do
      if ThisSArray[k].UnderTermName > ThisSArray[j].UnderTermName then
      begin
        var Temp := ThisSArray[k];
        ThisSArray[k] := ThisSArray[j];
        ThisSArray[j] := Temp;
      end;

  for k := 0 to i-2 do
  begin
    ThisSArray[k]^.UnderTermNext := ThisSArray[k+1];
    ThisSArray[k+1]^.UnderTermPrev := ThisSArray[k];
  end;
  ThisSArray[0]^.UnderTermPrev := nil;
  ThisSArray[i-1]^.UnderTermNext := nil;

  STToArrayAndSort := ThisSArray[0];
end;

// ------------------------------------------------------ Work with (ss)(s)term
function TToArray(var ThisArray: ForTArray): integer;
var
  i, k: integer;
begin
  k := -1;
  for i := 0 to TableSize-1 do
    if (TermTable[i] <> nil) and (TermTable[i]^.TermCurr <> nil) then
    begin
      Inc(k);
      while True do
      begin
        SetLength(ThisArray, k+1);
        ThisArray[k] := TermTable[i];

        ThisArray[k].TermCurr^.UnderTerm := STToArrayAndSort(ThisArray[k].TermCurr);

        if TermTable[i]^.TermNext <> nil then
        begin
          TermTable[i] := TermTable[i]^.TermNext;
          Inc(k);
        end
        else
          break;
      end;
    end;

  TToArray := k+1;
end;

procedure SortTerms(var ThisArray: ForTArray);
var
  i, j: integer;
begin
  for i := 0 to length(ThisArray)-2 do
    for j := i+1 to length(ThisArray)-1 do
      if ThisArray[i].TermCurr.TermName > ThisArray[j].TermCurr.TermName then
      begin
        var Temp := ThisArray[i];
        ThisArray[i] := ThisArray[j];
        ThisArray[j] := Temp;
      end;
end;
// -----------------------------------------------------------------------------

procedure SortInAlphabet(Memo: TMemo);
var
  i, NumT: integer;
begin
  NumT := TToArray(TArray);
  SortTerms(TArray);

  Memo.Clear;
  Memo.Lines.Add('Сортировка по алфовиту:');
  Memo.Lines.Add('');

  // Print these arrays
  for i := 0 to NumT - 1 do
  begin
    TermTemp := TArray[i];

    while TermTemp <> nil do
    begin
      StrPages := '';
      PageTempT := TermTemp^.TermCurr^.TermPage;
      while PageTempT <> nil do
      begin
        if StrPages = '' then StrPages := IntToStr(PageTempT^.Page)
        else
          StrPages := StrPages + ', ' + IntToStr(PageTempT^.Page);
        PageTempT := PageTempT^.PageNext;
      end;
      Memo.Lines.Add('');
      Memo.Lines.Add(TermTemp^.TermCurr^.TermName + ' (стр. ' + StrPages + ')');

      UnderTermTemp := TermTemp^.TermCurr^.UnderTerm;

      while UnderTermTemp <> nil do
      begin
        StrPages := '';
        PageTempST := UnderTermTemp^.UnderTermPage;
        while PageTempST <> nil do
        begin
          if StrPages = '' then StrPages := IntToStr(PageTempST^.Page)
          else
            StrPages := StrPages + ', ' + IntToStr(PageTempST^.Page);
          PageTempST := PageTempST^.PageNext;
        end;
        Memo.Lines.Add('- ' + UnderTermTemp^.UnderTermName + ' (стр. ' + StrPages + ')');

        UnderUnderTermTemp := UnderTermTemp^.UnderUnderTerm;

        while UnderUnderTermTemp <> nil do
        begin
          StrPages := '';
          PageTempSST := UnderUnderTermTemp^.UnderUnderTermPage;
          while PageTempSST <> nil do
          begin
            if StrPages = '' then StrPages := IntToStr(PageTempSST^.Page)
            else
              StrPages := StrPages + ', ' + IntToStr(PageTempSST^.Page);
            PageTempSST := PageTempSST^.PageNext;
          end;
          Memo.Lines.Add('-- ' + UnderUnderTermTemp^.UnderUnderTermName + ' (стр. ' + StrPages + ')');

            UnderUnderTermTemp := UnderUnderTermTemp^.UnderUnderTermNext;
        end;

          UnderTermTemp := UnderTermTemp^.UnderTermNext;
      end;

      TermTemp := TermTemp^.TermNext;
    end;
  end;
end;

procedure Swap(var F, S: integer);
var Temp: integer;
begin
  Temp := F;
  F := S;
  S := Temp;
end;

procedure SortPagesInTerm(var TermPages: PPages);
var
  TempPages: PPages;
begin
  while TermPages <> nil do
  begin
    TempPages := TermPages^.PageNext;
    while TempPages <> nil do
    begin
      if TermPages.Page > TempPages.Page then
        Swap(TermPages.Page, TempPages.Page);

      if TempPages^.PageNext <> nil then
        TempPages := TempPages^.PageNext
      else
        break;
    end;

    if TermPages^.PageNext <> nil then
      TermPages := TermPages^.PageNext
    else
      break;
  end;
end;

// ------------------------------------------------------- Sort in page numbers
function SSTToArrayAndSortInPageNums(ThisUnderTerm: PUnderTerm): PUnderUnderTerm;
var
  i, k, j: integer;
  ThisSSArray: array of PUnderUnderTerm;
begin
  i := 0;
  while True do
  begin
    Inc(i);
    SetLength(ThisSSArray, i);
    ThisSSArray[i-1] := ThisUnderTerm^.UnderUnderTerm;

    if ThisUnderTerm.UnderUnderTerm^.UnderUnderTermNext <> nil then
      ThisUnderTerm^.UnderUnderTerm := ThisUnderTerm.UnderUnderTerm^.UnderUnderTermNext
    else
      break;
  end;

  for k := 0 to i-2 do
    for j := k+1 to i-1 do
      if ThisSSArray[k].UnderUnderTermPage.Page > ThisSSArray[j].UnderUnderTermPage.Page then
      begin
        var Temp := ThisSSArray[k];
        ThisSSArray[k] := ThisSSArray[j];
        ThisSSArray[j] := Temp;
      end;

  for k := 0 to i-2 do
  begin
    ThisSSArray[k]^.UnderUnderTermNext := ThisSSArray[k+1];
    ThisSSArray[k+1]^.UnderUnderTermPrev := ThisSSArray[k];
  end;
  ThisSSArray[0]^.UnderUnderTermPrev := nil;
  ThisSSArray[i-1]^.UnderUnderTermNext := nil;

  SSTToArrayAndSortInPageNums := ThisSSArray[0];
end;

function STToArrayAndSortInPageNums(ThisTerm: PTermCurr): PUnderTerm;
var
  i, k, j: integer;
  ThisSArray: array of PUnderTerm;
begin
  i := 0;
  while True do
  begin
    Inc(i);
    SetLength(ThisSArray, i);
    ThisSArray[i-1] := ThisTerm^.UnderTerm;

    ThisSArray[i-1]^.UnderUnderTerm := SSTToArrayAndSortInPageNums(ThisTerm^.UnderTerm);

    if ThisTerm.UnderTerm^.UnderTermNext <> nil then
      ThisTerm^.UnderTerm := ThisTerm.UnderTerm^.UnderTermNext
    else
      break;
  end;

  for k := 0 to i-2 do
    for j := k+1 to i-1 do
      if ThisSArray[k].UnderTermPage.Page > ThisSArray[j].UnderTermPage.Page then
      begin
        var Temp := ThisSArray[k];
        ThisSArray[k] := ThisSArray[j];
        ThisSArray[j] := Temp;
      end;

  for k := 0 to i-2 do
  begin
    ThisSArray[k]^.UnderTermNext := ThisSArray[k+1];
    ThisSArray[k+1]^.UnderTermPrev := ThisSArray[k];
  end;
  ThisSArray[0]^.UnderTermPrev := nil;
  ThisSArray[i-1]^.UnderTermNext := nil;

  STToArrayAndSortInPageNums := ThisSArray[0];
end;

// Main part to sort in page numbers
procedure SortInPageNums(Memo: TMemo);
Var
  k, i: integer;
  SwapTerm: PTermCurr;
begin
  k := -1;
  for i := 0 to TableSize-1 do
    if (TermTable[i] <> nil) and (TermTable[i]^.TermCurr <> nil) then
    begin
      Inc(k);
      while True do
      begin
        SetLength(TArray, k+1);
        TArray[k] := TermTable[i];

        TArray[k].TermCurr^.UnderTerm := STToArrayAndSortInPageNums(TArray[k].TermCurr);

        if TermTable[i]^.TermNext <> nil then
        begin
          TermTable[i] := TermTable[i]^.TermNext;
          Inc(k);
        end
        else
          break;
      end;
    end;

  for i := 0 to length(TArray)-2 do
    for k := i+1 to length(TArray)-1 do
      if TArray[i].TermCurr.TermPage.Page > TArray[k].TermCurr.TermPage.Page then
      begin
        SwapTerm := TArray[i].TermCurr;
        TArray[i].TermCurr := TArray[k].TermCurr;
        TArray[k].TermCurr := SwapTerm;
      end;

  // Print these arrays
  Memo.Clear;
  Memo.Lines.Add('Сортировка по номерам страниц:');
  Memo.Lines.Add('');

  dec(k);
  for i := 0 to k do
  begin
    TermTemp := TArray[i];
    //StrPages := '';
    while TermTemp <> nil do
    begin
      StrPages := '';
      PageTempT := TermTemp^.TermCurr^.TermPage;
      while PageTempT <> nil do
      begin
        if StrPages = '' then StrPages := IntToStr(PageTempT^.Page)
        else
          StrPages := StrPages + ', ' + IntToStr(PageTempT^.Page);
        PageTempT := PageTempT^.PageNext;
      end;
      Memo.Lines.Add('');
      Memo.Lines.Add(TermTemp^.TermCurr^.TermName + ' (стр. ' + StrPages + ')');

      UnderTermTemp := TermTemp^.TermCurr^.UnderTerm;

      while UnderTermTemp <> nil do
      begin
        StrPages := '';
        PageTempST := UnderTermTemp^.UnderTermPage;
        while PageTempST <> nil do
        begin
          if StrPages = '' then StrPages := IntToStr(PageTempST^.Page)
          else
            StrPages := StrPages + ', ' + IntToStr(PageTempST^.Page);
          PageTempST := PageTempST^.PageNext;
        end;
        Memo.Lines.Add('- ' + UnderTermTemp^.UnderTermName + ' (стр. ' + StrPages + ')');

        UnderUnderTermTemp := UnderTermTemp^.UnderUnderTerm;

        while UnderUnderTermTemp <> nil do
        begin
          StrPages := '';
          PageTempSST := UnderUnderTermTemp^.UnderUnderTermPage;
          while PageTempSST <> nil do
          begin
            if StrPages = '' then StrPages := IntToStr(PageTempSST^.Page)
            else
              StrPages := StrPages + ', ' + IntToStr(PageTempSST^.Page);
            PageTempSST := PageTempSST^.PageNext;
          end;
          Memo.Lines.Add('-- ' + UnderUnderTermTemp^.UnderUnderTermName + ' (стр. ' + StrPages + ')');

            UnderUnderTermTemp := UnderUnderTermTemp^.UnderUnderTermNext;
        end;

          UnderTermTemp := UnderTermTemp^.UnderTermNext;
      end;

      TermTemp := TermTemp^.TermNext;
    end;
  end;
end;

procedure Search(Access: Integer; FindStr: String; Memo: TMemo);
var
  ThisTerm: PTerm;
  i: integer;
begin
  For i := 0 to TableSize-1 do
  begin
    if TermTable[i] <> nil then
    begin
      ThisTerm := TermTable[i];

      if (Access = 0) and (ThisTerm^.TermCurr <> nil) then
      begin
        while ThisTerm.TermCurr^.UnderTerm <> nil do
        begin
          if FindStr = ThisTerm.TermCurr.UnderTerm.UnderTermName then
            Memo.Lines.Add('- ' + ThisTerm.TermCurr.TermName);

          If ThisTerm.TermCurr.UnderTerm^.UnderTermNext <> nil then
            ThisTerm.TermCurr^.UnderTerm := ThisTerm.TermCurr.UnderTerm^.UnderTermNext
          else if ThisTerm^.TermNext <> nil then
            ThisTerm := ThisTerm^.TermNext
          else
            break;
        end;
      end
      else if (ThisTerm^.TermCurr <> nil) and (ThisTerm.TermCurr^.UnderTerm <> nil) then
      begin
        while ThisTerm.TermCurr.UnderTerm^.UnderUnderTerm <> nil do
        begin
          if FindStr = ThisTerm.TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermName then
            Memo.Lines.Add('- ' + ThisTerm.TermCurr.UnderTerm.UnderTermName);

          if ThisTerm.TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermNext <> nil then
            ThisTerm.TermCurr.UnderTerm^.UnderUnderTerm := ThisTerm.TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermNext
          else if ThisTerm.TermCurr.UnderTerm^.UnderTermNext <> nil then
            ThisTerm.TermCurr^.UnderTerm := ThisTerm.TermCurr.UnderTerm^.UnderTermNext
          else
            break;
        end;
      end;
    end;
  end;
  InStartPosition;
end;

procedure InStartPosition;
var
  i: 0..TableSize;
begin
  for i := 0 to TableSize-1 do
    while TermTable[i] <> nil do
    begin
      SortPagesInTerm(TermTable[i].TermCurr^.TermPage);
      while TermTable[i].TermCurr^.UnderTerm <> nil do
      begin
        SortPagesInTerm(TermTable[i].TermCurr.UnderTerm^.UnderTermPage);
        while (TermTable[i].TermCurr.UnderTerm^.UnderUnderTerm <> nil) do
        begin
          SortPagesInTerm(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage);
          // UnderUnderTerm pages
          while (TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage <> nil) and (TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PagePrev <> nil) do
            TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PagePrev;

          if TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPrev <> nil then
            TermTable[i].TermCurr.UnderTerm^.UnderUnderTerm := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPrev
          else
            break;
        end;
        // UnderTerm pages
        while (TermTable[i].TermCurr.UnderTerm^.UnderTermPage <> nil) and (TermTable[i].TermCurr.UnderTerm.UnderTermPage^.PagePrev <> nil) do
          TermTable[i].TermCurr.UnderTerm^.UnderTermPage := TermTable[i].TermCurr.UnderTerm.UnderTermPage^.PagePrev;

        if TermTable[i].TermCurr.UnderTerm^.UnderTermPrev <> nil then
          TermTable[i].TermCurr^.UnderTerm := TermTable[i].TermCurr.UnderTerm^.UnderTermPrev
        else
          break;
      end;
      // Term pages
      while (TermTable[i].TermCurr^.TermPage <> nil) and (TermTable[i].TermCurr.TermPage^.PagePrev <> nil) do
        TermTable[i].TermCurr^.TermPage := TermTable[i].TermCurr.TermPage^.PagePrev;

      if TermTable[i]^.TermPrev <> nil then
        TermTable[i] := TermTable[i]^.TermPrev
      else
        break;
    end;
end;


// --------------------------------------------- Hash function
function Hash(const S: string): integer;
var
  i, sum: integer;
begin
  sum := 0;
  for i := 1 to length(S) do
  begin
    Sum := Sum * 31 + ord(S[i]);
    Sum := Sum mod (2147483647 div 31);
  end;
  Result := Abs(sum mod TableSize);
end;                                           // ----


function SearchTerm(Term: PTerm): byte;
var
  TermSearch: PTerm;
  i: byte;
begin
  for i := 0 to TableSize-1 do
  begin
    TermSearch := TermTable[i];
    while TermSearch <> nil do
    begin
      if Term.TermCurr.TermName = TermSearch.TermCurr.TermName then
      begin
        SearchTerm := i;
        Exit;
      end;
      TermSearch := TermSearch^.TermPrev;
    end;
  end;
  SearchTerm := TableSize;
end;


procedure Add(ETerm, ETermPage,
              EUnderTerm, EUnderTermPage,
              EUnderUnderTerm, EUnderUnderTermPage: TEdit);
var
  Index: integer;
  i, TermInd: byte;
  UnderTermTemp: PUnderTerm;
  UnderUnderTermTemp: PUnderUnderTerm;
  PageSwapSST, PageTempSST, PageSwapST, PageTempST, PageSwapT, PageTempT: PPages;
  FoundTerm, FoundUnderTerm, FoundUnderUnderTerm: boolean;
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

  for i := 0 to TableSize-1 do
    if TermTable[i] <> nil then
      if TermTable[i]^.TermCurr^.TermName = ETerm.Text then
      begin
        FoundTerm := True;
        TermInd := i;
        UnderTermTemp := TermTable[i]^.TermCurr^.UnderTerm;
        while (UnderTermTemp <> nil) and (FoundUnderTerm = False) do
        begin
          if UnderTermTemp^.UnderTermName = EUnderTerm.Text then
          begin
            FoundUnderTerm := True;
            UnderUnderTermTemp := UnderTermTemp^.UnderUnderTerm;
            while (UnderUnderTermTemp <> nil) and (FoundUnderUnderTerm = False) do
            begin
              if UnderUnderTermTemp^.UnderUnderTermName = EUnderUnderTerm.Text then
              begin
                FoundUnderUnderTerm := True;

                // Add page if ness to SubSubTerm
                if UnderUnderTermTemp^.UnderUnderTermPage = nil then
                begin
                  New(UnderUnderTermTemp^.UnderUnderTermPage);
                  UnderUnderTermTemp^.UnderUnderTermPage^.Page := StrToInt(EUnderUnderTermPage.Text);
                  UnderUnderTermTemp^.UnderUnderTermPage^.PagePrev := nil;
                  UnderUnderTermTemp^.UnderUnderTermPage^.PageNext := nil;
                end
                else
                begin
                  PageTempSST := UnderUnderTermTemp^.UnderUnderTermPage;
                  while (PageTempSST^.PageNext <> nil) and (PageTempSST^.Page <> StrToInt(EUnderUnderTermPage.Text)) do
                    PageTempSST := PageTempSST^.PageNext;

                  if PageTempSST^.Page <> StrToInt(EUnderUnderTermPage.Text) then
                  begin
                    New(PageSwapSST);
                    PageSwapSST^.Page := StrToInt(EUnderUnderTermPage.Text);
                    PageSwapSST^.PagePrev := PageTempSST;
                    PageSwapSST^.PageNext := nil;
                    PageTempSST^.PageNext := PageSwapSST;
                  end;
                end;
              end;
              UnderUnderTermTemp := UnderUnderTermTemp^.UnderUnderTermPrev;
            end;

            // Add page if ness to SubTerm
            if UnderTermTemp^.UnderTermPage = nil then
            begin
              New(UnderTermTemp^.UnderTermPage);
              UnderTermTemp^.UnderTermPage^.Page := StrToInt(EUnderTermPage.Text);
              UnderTermTemp^.UnderTermPage^.PagePrev := nil;
              UnderTermTemp^.UnderTermPage^.PageNext := nil;
            end
            else
            begin
              PageTempST := UnderTermTemp^.UnderTermPage;
              while (PageTempST^.PageNext <> nil) and (PageTempST^.Page <> StrToInt(EUnderTermPage.Text)) do
                PageTempST := PageTempST^.PageNext;

              if PageTempST^.Page <> StrToInt(EUnderTermPage.Text) then
              begin
                New(PageSwapST);
                PageSwapST^.Page := StrToInt(EUnderTermPage.Text);
                PageSwapST^.PagePrev := PageTempST;
                PageSwapST^.PageNext := nil;
                PageTempST^.PageNext := PageSwapST;
              end;
            end;
          end;
          UnderTermTemp := UnderTermTemp^.UnderTermNext;
        end;

        // Add page if ness to Term
        if TermTable[i]^.TermCurr^.TermPage = nil then
        begin
          New(TermTable[i]^.TermCurr^.TermPage);
          TermTable[i]^.TermCurr^.TermPage^.Page := StrToInt(ETermPage.Text);
          TermTable[i]^.TermCurr^.TermPage^.PagePrev := nil;
          TermTable[i]^.TermCurr^.TermPage^.PageNext := nil;
        end
        else
        begin
          PageTempT := TermTable[i]^.TermCurr^.TermPage;
          while (PageTempT^.PageNext <> nil) and (PageTempT^.Page <> StrToInt(ETermPage.Text)) do
            PageTempT := PageTempT^.PageNext;

          if PageTempT^.Page <> StrToInt(ETermPage.Text) then
          begin
            New(PageSwapT);
            PageSwapT^.Page := StrToInt(ETermPage.Text);
            PageSwapT^.PagePrev := PageTempT;
            PageSwapT^.PageNext := nil;
            PageTempT^.PageNext := PageSwapT;
          end;
        end;
      end;

    // If not the same terms
    if not FoundTerm then
    begin
      TermTemp.TermCurr.TermName := ETerm.Text;
      TermTemp.TermCurr.TermPage.Page := StrToInt(ETermPage.Text);
    end;
    if not FoundUnderTerm then
    begin
      with TermTemp.TermCurr.UnderTerm^ do
      begin
        UnderTermName := EUnderTerm.Text;
        UnderTermPage.Page := StrToInt(EUnderTermPage.Text);
        UnderTermNext := nil;
        UnderTermPrev := nil;
      end;
    end;
    if not FoundUnderUnderTerm then
    begin
      with TermTemp.TermCurr.UnderTerm.UnderUnderTerm^ do
      begin
        UnderUnderTermName := EUnderUnderTerm.Text;
        UnderUnderTermPage.Page := StrToInt(EUnderUnderTermPage.Text);
        UnderUnderTermNext := nil;
        UnderUnderTermPrev := nil;
      end;
    end;

    // For HashTable
    if not FoundTerm then
    begin
      Index := Hash(TermTemp.TermCurr.TermName);

      TermTemp^.TermPrev := TermTable[Index];
      if TermTable[Index] <> nil then
      begin
        TermTable[Index]^.TermNext := TermTable[Index];
        TermTable[Index]^.TermCurr := TermTemp.TermCurr;
        TermTable[Index]^.TermNext^.TermPrev := TermTemp;
      end
      else
      begin
        TermTemp^.TermNext := nil;
        TermTable[Index] := TermTemp;
      end;
    end
    else if FoundUnderTerm and not FoundUnderUnderTerm then
    begin
      UnderTermTemp := TermTable[TermInd]^.TermCurr^.UnderTerm;
      while UnderTermTemp <> nil do
      begin
        if UnderTermTemp^.UnderTermName = EUnderTerm.Text then
        begin
          UnderUnderTermTemp := UnderTermTemp^.UnderUnderTerm;
          UnderTermTemp^.UnderUnderTerm := TermTemp^.TermCurr^.UnderTerm^.UnderUnderTerm;
          UnderTermTemp^.UnderUnderTerm^.UnderUnderTermNext := UnderUnderTermTemp;
          if UnderUnderTermTemp <> nil then
            UnderTermTemp^.UnderUnderTerm^.UnderUnderTermNext^.UnderUnderTermPrev := UnderTermTemp^.UnderUnderTerm;
        end;
        UnderTermTemp := UnderTermTemp^.UnderTermNext;
      end;
    end
    else if not FoundUnderTerm then
    begin
      UnderTermTemp := TermTable[TermInd]^.TermCurr^.UnderTerm;
      TermTable[TermInd]^.TermCurr^.UnderTerm := TermTemp.TermCurr.UnderTerm;
      TermTable[TermInd]^.TermCurr^.UnderTerm^.UnderTermNext := UnderTermTemp;
      if UnderTermTemp <> nil then
        TermTable[TermInd]^.TermCurr^.UnderTerm^.UnderTermNext^.UnderTermPrev := TermTable[TermInd]^.TermCurr^.UnderTerm;
    end;
//  end;
end;


procedure Delete(DeepPoint: Integer; MemoSelected: TMemo; ETerm, EUnderTerm, EUnderUnderTerm: TEdit);
var
  i: byte;
  PageSwap: PPages;
begin
  InStartPosition;
  for i := 0 to TableSize - 1 do
  begin
    TermTemp := TermTable[i];
    while TermTemp <> nil do
    begin

      // If found
      if (DeepPoint = 0) and (TermTemp^.TermCurr^.TermName = MemoSelected.Lines[0]) then
      begin
        TermSwapPrev := TermTemp^.TermPrev;
        TermTemp^.TermCurr := nil;
        TermTemp := TermSwapPrev;
        TermTable[i] := TermTemp;
        Dispose(TermTemp);
        Dispose(TermTable[i]);
      end;
      while (TermTemp <> nil)
        and (TermTemp.TermCurr^.TermPage <> nil) do
      begin
        if (DeepPoint = 3)
          and (TermTemp^.TermCurr^.TermPage^.Page = StrToInt(MemoSelected.Lines[0])) then
        begin
          // Delete page
          PageSwap := TermTemp^.TermCurr^.TermPage^.PagePrev;
          if PageSwap <> nil then
          begin
            PageSwap^.PageNext := TermTemp^.TermCurr^.TermPage^.PageNext;
            if PageSwap^.PageNext <> nil then
              PageSwap^.PageNext^.PagePrev := TermTemp^.TermCurr^.TermPage^.PagePrev;
          end;
          if (TermTable[i].TermCurr^.TermPage <> nil) and (TermTable[i].TermCurr.TermPage^.PageNext <> nil) then
            TermTable[i].TermCurr^.TermPage := TermTable[i].TermCurr.TermPage^.PageNext
          else if (TermTable[i].TermCurr^.TermPage <> nil) and not (TermTable[i].TermCurr.TermPage^.PageNext <> nil) then
            TermTable[i].TermCurr^.TermPage := PageSwap;
          if (PageSwap = nil) and (TermTable[i].TermCurr^.TermPage <> nil) then
          begin
            TermTable[i].TermCurr.TermPage^.PagePrev := PageSwap;
            Dispose(TermTable[i]^.TermCurr^.TermPage^.PagePrev);
          end
          else if PageSwap = nil then
            Dispose(TermTable[i]^.TermCurr^.TermPage);
        end;

        if (TermTemp.TermCurr^.TermPage <> nil)
          and (TermTemp.TermCurr.TermPage^.PageNext <> nil) then
          TermTemp.TermCurr^.TermPage := TermTemp.TermCurr.TermPage^.PageNext
        else
          break;
      end;

      if TermTemp <> nil then
        UnderTermTemp := TermTemp^.TermCurr^.UnderTerm
      else
      begin
        UnderUnderTermTemp := nil;
        UnderTermTemp := nil;
      end;

      while UnderTermTemp <> nil do
      begin

        // If found
        if (DeepPoint = 1) and (UnderTermTemp^.UnderTermName = MemoSelected.Lines[0]) then
        begin
          UnderTermSwapPrev := UnderTermTemp^.UnderTermPrev;
          UnderTermSwapNext := UnderTermTemp^.UnderTermNext;
          if UnderTermSwapNext = nil then
          begin
            if UnderTermSwapPrev <> nil then
              UnderTermSwapPrev^.UnderTermNext := UnderTermSwapNext;
            TermTable[i]^.TermCurr^.UnderTerm := UnderTermSwapPrev;
          end
          else
          begin
            UnderTermSwapNext^.UnderTermPrev := UnderTermSwapPrev;
            TermTable[i]^.TermCurr^.UnderTerm := UnderTermSwapNext;
          end;
        end;

        while (TermTemp.TermCurr^.UnderTerm <> nil)
          and (TermTemp.TermCurr.UnderTerm^.UnderTermPage <> nil) do
        begin
          if (DeepPoint = 3)
            and (TermTemp.TermCurr.UnderTerm.UnderTermPage.Page = StrToInt(MemoSelected.Lines[0])) then
          begin

            // Delete page
            PageSwap := TermTemp.TermCurr.UnderTerm.UnderTermPage^.PagePrev;
            if PageSwap <> nil then
            begin
              PageSwap^.PageNext := TermTemp.TermCurr.UnderTerm.UnderTermPage^.PageNext;
              if PageSwap^.PageNext <> nil then
                PageSwap^.PageNext^.PagePrev := TermTemp.TermCurr.UnderTerm.UnderTermPage^.PagePrev;
            end;
            if (TermTable[i].TermCurr.UnderTerm^.UnderTermPage <> nil)
              and (TermTable[i].TermCurr.UnderTerm.UnderTermPage^.PageNext <> nil) then
              TermTable[i].TermCurr.UnderTerm^.UnderTermPage := TermTable[i].TermCurr.UnderTerm.UnderTermPage^.PageNext
            else if (TermTable[i].TermCurr.UnderTerm^.UnderTermPage <> nil)
              and not (TermTable[i].TermCurr.UnderTerm.UnderTermPage^.PageNext <> nil) then
              TermTable[i].TermCurr.UnderTerm^.UnderTermPage := PageSwap;
            if (PageSwap = nil) and (TermTable[i].TermCurr.UnderTerm^.UnderTermPage <> nil) then
            begin
              TermTable[i].TermCurr.UnderTerm.UnderTermPage^.PagePrev := PageSwap;
              Dispose(TermTable[i].TermCurr.UnderTerm.UnderTermPage^.PagePrev);
            end
            else if PageSwap = nil then
              Dispose(TermTable[i].TermCurr.UnderTerm^.UnderTermPage);
          end;

          if (TermTemp.TermCurr.UnderTerm^.UnderTermPage <> nil)
            and (TermTemp.TermCurr.UnderTerm.UnderTermPage^.PageNext <> nil) then
            TermTemp.TermCurr.UnderTerm^.UnderTermPage := TermTemp.TermCurr.UnderTerm.UnderTermPage^.PageNext
          else
            break;
        end;

        if UnderTermTemp <> nil then
          UnderUnderTermTemp := UnderTermTemp^.UnderUnderTerm
        else
          UnderUnderTermTemp := nil;
        while UnderUnderTermTemp <> nil do
        begin

          // If found
          if (DeepPoint = 2) and (UnderUnderTermTemp^.UnderUnderTermName = MemoSelected.Lines[0]) then
          begin
            UnderUnderTermSwapPrev := UnderUnderTermTemp^.UnderUnderTermPrev;
            UnderUnderTermSwapNext := UnderUnderTermTemp^.UnderUnderTermNext;
            if UnderUnderTermSwapNext = nil then
            begin
              if UnderUnderTermSwapPrev <> nil then
                UnderUnderTermSwapPrev^.UnderUnderTermNext := UnderUnderTermSwapNext;
              TermTable[i]^.TermCurr^.UnderTerm^.UnderUnderTerm := UnderUnderTermSwapPrev;
            end
            else
            begin
              UnderUnderTermSwapNext^.UnderUnderTermPrev := UnderUnderTermSwapPrev;
              TermTable[i]^.TermCurr^.UnderTerm^.UnderUnderTerm := UnderUnderTermSwapNext;
            end;
          end;

          while (TermTemp <> nil)
            and (TermTemp.TermCurr^.UnderTerm <> nil)
            and (TermTemp.TermCurr.UnderTerm^.UnderUnderTerm <> nil)
            and (TermTemp.TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage <> nil) do
          begin
            if (DeepPoint = 3)
              and (TermTemp.TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage.Page = StrToInt(MemoSelected.Lines[0])) then
            begin

              // Delete page
              PageSwap := TermTemp.TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PagePrev;
              if PageSwap <> nil then
              begin
                PageSwap^.PageNext := TermTemp.TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PageNext;
                if PageSwap^.PageNext <> nil then
                  PageSwap^.PageNext^.PagePrev := TermTemp.TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PagePrev;
              end;
              if (TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage <> nil)
                and (TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PageNext <> nil) then
                TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage := TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PageNext
              else if (TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage <> nil)
                and not (TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PageNext <> nil) then
                TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage := PageSwap;

              if (PageSwap = nil) and (TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage <> nil) then
              begin
                TermTable[i].TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PagePrev := PageSwap;
                Dispose(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage^.PagePrev);
              end
              else if PageSwap = nil then
                Dispose(TermTable[i].TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage);
            end;

            if (TermTemp.TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage <> nil)
              and (TermTemp.TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PageNext <> nil) then
              TermTemp.TermCurr.UnderTerm.UnderUnderTerm^.UnderUnderTermPage := TermTemp.TermCurr.UnderTerm.UnderUnderTerm.UnderUnderTermPage^.PageNext
            else
              break;
          end;

          if UnderUnderTermTemp <> nil then
          begin
            UnderUnderTermTemp := UnderUnderTermTemp^.UnderUnderTermNext;
            if (TermTable[i]^.TermCurr^.UnderTerm^.UnderUnderTerm <> nil)
              and (TermTable[i]^.TermCurr^.UnderTerm^.UnderUnderTerm^.UnderUnderTermNext <> nil) then
              TermTable[i]^.TermCurr^.UnderTerm^.UnderUnderTerm := TermTable[i]^.TermCurr^.UnderTerm^.UnderUnderTerm^.UnderUnderTermNext;
          end;
        end;

        if UnderTermTemp^.UnderTermNext <> nil then
        begin
          UnderTermTemp := UnderTermTemp^.UnderTermNext;
          if (TermTable[i]^.TermCurr^.UnderTerm <> nil)
            and (TermTable[i]^.TermCurr^.UnderTerm^.UnderTermNext <> nil) then
            TermTable[i]^.TermCurr^.UnderTerm := TermTable[i]^.TermCurr^.UnderTerm^.UnderTermNext;
        end
        else
          break;
      end;

      if (TermTemp <> nil) and (TermTemp^.TermNext <> nil) then
        TermTemp := TermTemp^.TermNext
      else if (TermTemp <> nil) and (TermTemp.TermCurr = nil) then
        TermTemp := nil
      else
        break;
    end;
  end;
end;

// -------------------------------------------------------- Print List of Terms
procedure PrintList(ShowInMemo: TMemo);
var
  i: byte;
  StrPages: string;
  UnderTermTemp: PUnderTerm;
  UnderUnderTermTemp: PUnderUnderTerm;
  PageTempSST, PageTempST, PageTempT: PPages;
begin
  InStartPosition;

  // Print on memo
  ShowInMemo.Clear;
  ShowInMemo.Font.Color := clWindowText;
  ShowInMemo.Lines.Add('Словарь:');
  for i := 0 to TableSize - 1 do
  begin
    TermTemp := TermTable[i];

    while TermTemp <> nil do
    begin
      StrPages := '';
      PageTempT := TermTemp^.TermCurr^.TermPage;
      while PageTempT <> nil do
      begin
        if StrPages = '' then StrPages := IntToStr(PageTempT^.Page)
        else
          StrPages := StrPages + ', ' + IntToStr(PageTempT^.Page);
        PageTempT := PageTempT^.PageNext;
      end;
      ShowInMemo.Lines.Add('');
      ShowInMemo.Lines.Add(TermTemp^.TermCurr^.TermName + ' (стр. ' + StrPages + ')');

      UnderTermTemp := TermTemp^.TermCurr^.UnderTerm;

      while UnderTermTemp <> nil do
      begin
        StrPages := '';
        PageTempST := UnderTermTemp^.UnderTermPage;
        while PageTempST <> nil do
        begin
          if StrPages = '' then StrPages := IntToStr(PageTempST^.Page)
          else
            StrPages := StrPages + ', ' + IntToStr(PageTempST^.Page);
          PageTempST := PageTempST^.PageNext;
        end;
        ShowInMemo.Lines.Add('- ' + UnderTermTemp^.UnderTermName + ' (стр. ' + StrPages + ')');

        UnderUnderTermTemp := UnderTermTemp^.UnderUnderTerm;

        while UnderUnderTermTemp <> nil do
        begin
          StrPages := '';
          PageTempSST := UnderUnderTermTemp^.UnderUnderTermPage;
          while PageTempSST <> nil do
          begin
            if StrPages = '' then StrPages := IntToStr(PageTempSST^.Page)
            else
              StrPages := StrPages + ', ' + IntToStr(PageTempSST^.Page);
            PageTempSST := PageTempSST^.PageNext;
          end;
          ShowInMemo.Lines.Add('-- ' + UnderUnderTermTemp^.UnderUnderTermName + ' (стр. ' + StrPages + ')');

          if Movement = 'Delete' then
            UnderUnderTermTemp := UnderUnderTermTemp^.UnderUnderTermPrev
          else
            UnderUnderTermTemp := UnderUnderTermTemp^.UnderUnderTermNext;
        end;

        if Movement = 'Delete' then
          UnderTermTemp := UnderTermTemp^.UnderTermPrev
        else
          UnderTermTemp := UnderTermTemp^.UnderTermNext;
      end;

      TermTemp := TermTemp^.TermNext;
    end;
  end;
end;

end.
