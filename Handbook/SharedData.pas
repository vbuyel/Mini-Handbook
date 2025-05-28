unit SharedData;

interface

type
  PTerm = ^TermStruc;
  PUnderTerm = ^UnderTermStruc;
  PUnderUnderTerm = ^UnderUnderTermStruc;
  PTermCurr = ^TermCurrStruc;
  PUnderTermCurr = ^UnderTermStruc;
  PUnderUnderTermCurr = ^UnderUnderTermStruc;
  PPages = ^PagesStruc;

  // Term structure
  TermStruc = record
    TermPrev: PTerm;
    TermCurr: PTermCurr;
    TermNext: PTerm;
  end;

  TermCurrStruc = record
    TermName: string;
    TermPage: PPages;
    UnderTerm: PUnderTerm;
  end;

  // SubTerm structure
  UnderTermStruc = record
    UnderTermPrev: PUnderTerm;
    UnderTermName: string;
    UnderTermPage: PPages;
    UnderUnderTerm: PUnderUnderTerm;
    UnderTermNext: PUnderTerm;
  end;

  // SubSubTerm structure
  UnderUnderTermStruc = record
    UnderUnderTermPrev: PUnderUnderTerm;
    UnderUnderTermName: string;
    UnderUnderTermPage: PPages;
    UnderUnderTermNext: PUnderUnderTerm;
  end;

  PagesStruc = record
    PagePrev: PPages;
    Page: integer;
    PageNext: PPages;
  end;

const
  TableSize = 101;

var
  StrPages: string;
  TermSwapPrev, TermSwapNext: PTerm;
  UnderTermTemp, UnderTermSwapPrev, UnderTermSwapNext: PUnderTerm;
  UnderUnderTermTemp, UnderUnderTermSwapPrev, UnderUnderTermSwapNext: PUnderUnderTerm;
  PageTempSST, PageTempST, PageTempT: PPages;
  TermTemp: PTerm;
  AllErrors, Error, CheckedInt: integer;
  CheckingString: string;
  TermTable: array[0..TableSize-1] of PTerm;

implementation

end.
