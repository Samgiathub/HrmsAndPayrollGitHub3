using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0000FormDetail
{
    public decimal FormId { get; set; }

    public string? FormUrl { get; set; }

    public decimal IsAdminEssHrms { get; set; }

    public byte IsActive { get; set; }
}
