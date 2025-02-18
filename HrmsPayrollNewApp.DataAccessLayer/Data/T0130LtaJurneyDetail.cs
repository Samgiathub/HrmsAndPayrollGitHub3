using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130LtaJurneyDetail
{
    public decimal LtaJId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal LmAppId { get; set; }

    public DateTime? JrDate { get; set; }

    public string? FromPlace { get; set; }

    public string? ToPlace { get; set; }

    public string? Route { get; set; }

    public string? ModeOfTravel { get; set; }

    public decimal? Fare { get; set; }

    public string? FileName { get; set; }

    public decimal? LmAprId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0110LtaMedicalApplication LmApp { get; set; } = null!;

    public virtual T0120LtaMedicalApproval? LmApr { get; set; }
}
