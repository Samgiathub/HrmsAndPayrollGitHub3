using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020DependencyMaster
{
    public int CmpId { get; set; }

    public int DependencyId { get; set; }

    public string DependencyCode { get; set; } = null!;

    public string DependencyType { get; set; } = null!;

    public int IsActive { get; set; }

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
