using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010CompanyDirectorDetail
{
    public decimal DirectorId { get; set; }

    public decimal CmpId { get; set; }

    public string DirectorName { get; set; } = null!;

    public string DirectorAddress { get; set; } = null!;

    public DateTime? DirectorDob { get; set; }

    public string DirectorBranch { get; set; } = null!;

    public string DirectorDesignation { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
