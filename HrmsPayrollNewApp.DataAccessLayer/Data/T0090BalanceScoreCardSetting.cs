using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090BalanceScoreCardSetting
{
    public decimal BscSettingId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BscStatus { get; set; }

    public int FinYear { get; set; }

    public DateTime Createddate { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public decimal CreatedBy { get; set; }

    public decimal? ModifiedBy { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0095BalanceScoreCardSettingDetail> T0095BalanceScoreCardSettingDetails { get; set; } = new List<T0095BalanceScoreCardSettingDetail>();

    public virtual ICollection<T0110BalanceScoreCardSettingApproval> T0110BalanceScoreCardSettingApprovals { get; set; } = new List<T0110BalanceScoreCardSettingApproval>();
}
