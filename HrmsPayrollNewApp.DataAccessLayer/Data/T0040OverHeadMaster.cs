using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040OverHeadMaster
{
    public int OverheadId { get; set; }

    public decimal? ProjectCost { get; set; }

    public string? OverHeadMonth { get; set; }

    public decimal? OverHeadYear { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? CreatedBy { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ExchangeRate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040TsProjectMaster? Project { get; set; }
}
