using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200QuestionExitAnalysisMaster
{
    public decimal QuestId { get; set; }

    public decimal CmpId { get; set; }

    public string? Question { get; set; }

    public decimal QuestionType { get; set; }

    public string? QuestionOptions { get; set; }

    public decimal SortingNo { get; set; }

    public string? StrDesigId { get; set; }

    public byte AutoAssign { get; set; }

    public decimal GroupId { get; set; }
}
