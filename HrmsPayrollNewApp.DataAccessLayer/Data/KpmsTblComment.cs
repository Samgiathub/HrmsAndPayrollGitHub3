using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsTblComment
{
    public int Commid { get; set; }

    public int? Eid { get; set; }

    public string? Comment { get; set; }

    public int? GoalSheetId { get; set; }

    public string? Date { get; set; }

    public int? GoalAltId { get; set; }

    public int? CmpId { get; set; }
}
