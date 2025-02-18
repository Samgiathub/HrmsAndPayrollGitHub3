using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsReportingManager
{
    public int RptId { get; set; }

    public int? RptLevel { get; set; }

    public int? EmpId { get; set; }

    public int? RmId { get; set; }

    public int? CmpId { get; set; }
}
