using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100Gratuity
{
    public decimal GrId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public DateTime PaidDate { get; set; }

    public decimal GrCalcAmount { get; set; }

    public decimal GrDays { get; set; }

    public decimal GrPercentage { get; set; }

    public decimal GrAmount { get; set; }

    public string GrCalcType { get; set; } = null!;

    public byte GrFnf { get; set; }

    public decimal GrYears { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0110GratuityDetail> T0110GratuityDetails { get; set; } = new List<T0110GratuityDetail>();
}
