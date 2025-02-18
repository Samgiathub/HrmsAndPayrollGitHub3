using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150TravelProjectVendorDetail
{
    public decimal ProjectId { get; set; }

    public string ProjectName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal TravelApprovalId { get; set; }
}
