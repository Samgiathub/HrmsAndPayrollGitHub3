using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050ProductionDetailsImport
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmployeeId { get; set; }

    public decimal? ProductionMonth { get; set; }

    public decimal? ProductionYear { get; set; }

    public decimal? ProductionPcs { get; set; }

    public decimal? ProductionAmount { get; set; }

    public decimal? IncentiveAmount { get; set; }

    public decimal? CardAmount { get; set; }

    public decimal? GrossAmount { get; set; }
}
