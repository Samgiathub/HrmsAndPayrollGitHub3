using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200QuestionExitAnalysisMaster
{
    public decimal CmpId { get; set; }

    public decimal QuestId { get; set; }

    public string? Question { get; set; }

    public string QuestionType { get; set; } = null!;

    public string? QuestionOptions { get; set; }

    public string? StrDesigId { get; set; }

    public decimal SortingNo { get; set; }

    public byte AutoAssign { get; set; }

    public string? GroupName { get; set; }
}
