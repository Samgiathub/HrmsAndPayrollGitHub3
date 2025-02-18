using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpReportingDetailReplaceHistory
{
    public int RowId { get; set; }

    public int EmpId { get; set; }

    public int OldREmpId { get; set; }

    public int NewREmpId { get; set; }

    public int CmpId { get; set; }

    public DateTime ChangeDate { get; set; }

    public string? Comment { get; set; }
}
