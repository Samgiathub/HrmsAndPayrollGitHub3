using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050SubBranch
{
    public decimal SubBranchId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public string? SubBranchCode { get; set; }

    public string? SubBranchName { get; set; }

    public string? SubBranchDescription { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public decimal CityId { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }
}
