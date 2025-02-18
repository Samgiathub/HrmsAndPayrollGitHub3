using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpHrDocDetail
{
    public decimal EmpDocId { get; set; }

    public decimal? HrDocId { get; set; }

    public int? Accetpeted { get; set; }

    public DateTime? AcceptedDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? DocContent { get; set; }

    public decimal? LoginId { get; set; }

    public byte? Type { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0040HrDocMaster? HrDoc { get; set; }
}
