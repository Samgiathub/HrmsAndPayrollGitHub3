using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080FileHistoryRemoved
{
    public int FhId { get; set; }

    public decimal? FileAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? FileAprId { get; set; }

    public string TransType { get; set; } = null!;

    public string FileNumber { get; set; } = null!;
}
