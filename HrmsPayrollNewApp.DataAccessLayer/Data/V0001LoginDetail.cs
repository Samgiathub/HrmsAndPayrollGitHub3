using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0001LoginDetail
{
    public string LoginType { get; set; } = null!;

    public decimal LoginRightsId { get; set; }

    public decimal LoginTypeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IsSave { get; set; }

    public decimal IsEdit { get; set; }

    public decimal IsDelete { get; set; }

    public decimal IsReport { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal LoginId { get; set; }
}
